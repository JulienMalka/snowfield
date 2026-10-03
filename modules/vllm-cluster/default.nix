{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.luj.vllm-cluster;
  ic = cfg.interconnect;
  ifaces = lib.attrNames ic.addresses;
  isHead = cfg.nodeRank == 0;
  hostIp = ic.addresses.${ic.primaryInterface};

  containerName = "vllm-cluster";
  serviceName = "podman-${containerName}";

  peerAddresses = lib.filter (a: a != hostIp) cfg.nodeAddresses;

  # A rank that just started ignores resync requests for this long. It is
  # what stops two nodes from restarting each other forever: A starts and
  # pokes B, B restarts and pokes A back, and A, being fresh, stays up.
  resyncGraceSeconds = 90;

  # Run on every start of this node's rank: ask each peer to restart its own.
  pokePeers = pkgs.writeShellScript "vllm-cluster-poke-peers" ''
    for peer in ${lib.escapeShellArgs peerAddresses}; do
      ${pkgs.coreutils}/bin/timeout 3 ${pkgs.bash}/bin/bash -c \
        "exec 3<>/dev/tcp/$peer/${toString cfg.resyncPort}" 2>/dev/null \
        || echo "vllm-cluster: peer $peer did not take the resync request" >&2
    done
    exit 0
  '';

  # Run on a peer's request: restart our rank unless it only just started.
  resync = pkgs.writeShellScript "vllm-cluster-resync" ''
    systemctl=${config.systemd.package}/bin/systemctl
    unit=${serviceName}.service
    if [ "$($systemctl is-active "$unit")" != active ]; then
      echo "$unit is not active (already restarting); ignoring resync request"
      exit 0
    fi
    since=$($systemctl show "$unit" -p ActiveEnterTimestampMonotonic --value)
    now=$(${pkgs.gawk}/bin/awk '{ printf "%d", $1 * 1000000 }' /proc/uptime)
    if [ $(( (now - since) / 1000000 )) -lt ${toString resyncGraceSeconds} ]; then
      echo "$unit started less than ${toString resyncGraceSeconds}s ago; ignoring resync request"
      exit 0
    fi
    echo "peer restarted its rank; restarting $unit to rendezvous with it"
    exec $systemctl restart --no-block "$unit"
  '';

  # Compile/JIT artefacts the Spark vLLM image writes under /root: keep them
  # on the host so a container restart does not recompile every kernel.
  cacheDirs = [
    "/root/.cache/huggingface"
    "/root/.cache/vllm"
    "/root/.cache/flashinfer"
    "/root/.cache/b12x"
    "/root/.triton"
    "/root/.tilelang"
  ];

  serveArgs = [
    "serve"
    cfg.model
    "--host"
    cfg.host
    "--port"
    (toString cfg.port)
    "--tensor-parallel-size"
    (toString cfg.nodes)
  ]
  ++ lib.optionals (cfg.servedModelNames != [ ]) ([ "--served-model-name" ] ++ cfg.servedModelNames)
  ++ cfg.extraArgs
  # Multi-node without Ray: every node runs the same `vllm serve`, torch
  # rendezvous happens on the head's master port, and only the head serves
  # the API. Workers are headless.
  ++ [
    "--distributed-executor-backend"
    "mp"
    "--nnodes"
    (toString cfg.nodes)
    "--node-rank"
    (toString cfg.nodeRank)
    "--master-addr"
    cfg.masterAddr
    "--master-port"
    (toString cfg.masterPort)
  ]
  ++ lib.optional (!isHead) "--headless";
in
{
  options.luj.vllm-cluster = {
    enable = lib.mkEnableOption "a multi-node vLLM tensor-parallel cluster member";

    image = lib.mkOption {
      type = lib.types.str;
      description = ''
        Container image carrying vLLM. Pin it by digest: every node of the
        cluster must run the exact same build or NCCL/torch fail to rendezvous
        or, worse, silently run slow.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      description = "HuggingFace model ID to serve.";
    };

    servedModelNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Aliases the model answers to on /v1/models.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address the head node binds the API to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port of the OpenAI-compatible API on the head node.";
    };

    nodes = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Number of nodes, i.e. the tensor-parallel size (one GPU per node).";
    };

    nodeRank = lib.mkOption {
      type = lib.types.ints.unsigned;
      description = "This node's rank. Rank 0 is the head and serves the API.";
    };

    nodeAddresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Address of every node on the primary interconnect interface, in rank
        order. The first one is the head.
      '';
      example = [
        "192.168.100.11"
        "192.168.100.12"
      ];
    };

    masterAddr = lib.mkOption {
      type = lib.types.str;
      default = builtins.head cfg.nodeAddresses;
      defaultText = lib.literalExpression "builtins.head config.luj.vllm-cluster.nodeAddresses";
      description = "Head node address on the interconnect, used for torch rendezvous.";
    };

    resyncPort = lib.mkOption {
      type = lib.types.port;
      default = 29599;
      description = ''
        Port, on the interconnect only, on which a node accepts "restart your
        rank" requests from its peers. See the resync units below.
      '';
    };

    masterPort = lib.mkOption {
      type = lib.types.port;
      default = 29501;
      description = "Torch rendezvous port on the head node.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional `vllm serve` arguments, identical on every node.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment for the container, identical on every node.";
    };

    interconnect = {
      addresses = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = ''
          IPv4 address, one per ConnectX interface, each on its own /24. On
          the DGX Spark one QSFP port is two 100G MACs on separate PCIe links
          (enp1s0f0np0 and enP2p1s0f0np0 are the same socket); both need an
          address so RoCEv2 gets a GID on each and NCCL can stripe across them.
        '';
        example = {
          enp1s0f0np0 = "192.168.100.11";
          enP2p1s0f0np0 = "192.168.101.11";
        };
      };

      primaryInterface = lib.mkOption {
        type = lib.types.str;
        description = "Interface carrying the TCP control plane (torch, gloo, NCCL bootstrap).";
      };

      rdmaDevices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "RDMA devices NCCL may use, e.g. the two mlx5 twins behind the cabled port.";
        example = [
          "mlx5_0"
          "mlx5_2"
        ];
      };

      mtu = lib.mkOption {
        type = lib.types.int;
        default = 9000;
        description = "Jumbo frames on a direct cable, so RoCE negotiates a 4096-byte path MTU.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # The option only exists on machines importing the dgx-spark module.
      (lib.optionalAttrs (options.hardware ? dgx-spark) {
        # The ConnectX-7 hot-plug power saving gates the NIC at boot: with the
        # cable already seated, both ends come up with "no partner detected"
        # and the link only appears after a (real or emulated) re-plug. The
        # cable is permanent on a cluster node, so keep the NIC powered from
        # enumeration on. Hot-plug detection goes with it: the cable must be
        # in at boot.
        hardware.dgx-spark.connectx7Hotplug = lib.mkDefault false;
      })
      {
        assertions = [
          {
            assertion = lib.hasAttr ic.primaryInterface ic.addresses;
            message = "luj.vllm-cluster.interconnect.primaryInterface must be one of interconnect.addresses.";
          }
          {
            assertion = cfg.nodeRank < cfg.nodes;
            message = "luj.vllm-cluster.nodeRank must be below nodes.";
          }
          {
            assertion =
              lib.length cfg.nodeAddresses == cfg.nodes && lib.elemAt cfg.nodeAddresses cfg.nodeRank == hostIp;
            message = ''
              luj.vllm-cluster.nodeAddresses must list one address per node in
              rank order, and this node's entry must be its own address on the
              primary interconnect interface (${hostIp}).
            '';
          }
        ];

        # Static addressing of the QSFP link. NetworkManager would otherwise
        # sit in "connecting" trying DHCP on it forever.
        networking.networkmanager.unmanaged = map (i: "interface-name:${i}") ifaces;
        networking.interfaces = lib.mapAttrs (_: address: {
          useDHCP = false;
          inherit (ic) mtu;
          ipv4.addresses = [
            {
              inherit address;
              prefixLength = 24;
            }
          ];
        }) ic.addresses;

        # Both MACs share one L2 segment, so by default the kernel answers ARP for
        # either address from whichever interface it likes and the peer ends up
        # with the wrong path in its neighbour table. Answer only for the address
        # on the receiving interface, and source announcements from it.
        boot.kernel.sysctl = lib.listToAttrs (
          lib.concatMap (i: [
            (lib.nameValuePair "net.ipv4.conf.${i}.arp_ignore" 1)
            (lib.nameValuePair "net.ipv4.conf.${i}.arp_announce" 2)
          ]) ifaces
        );

        # The only peer on the cable is the other node; torch, gloo and NCCL all
        # use ephemeral ports on it.
        networking.firewall.trustedInterfaces = ifaces;

        systemd.tmpfiles.rules = map (d: "d ${d} 0755 root root -") cacheDirs;

        virtualisation.oci-containers.containers.${containerName} = {
          inherit (cfg) image;
          autoStart = true;
          pull = "missing";
          # RDMA needs pinned memory and the verbs devices; the GPU comes in
          # through CDI, generated on boot by nvidia-container-toolkit.
          privileged = true;
          networks = [ "host" ];
          devices = [
            "nvidia.com/gpu=all"
            "/dev/infiniband"
          ];
          extraOptions = [
            "--ipc=host"
            "--ulimit=memlock=-1:-1"
            "--ulimit=nofile=1048576:1048576"
          ];
          volumes = map (d: "${d}:${d}") cacheDirs;
          environment = {
            VLLM_HOST_IP = hostIp;
            NCCL_SOCKET_IFNAME = ic.primaryInterface;
            GLOO_SOCKET_IFNAME = ic.primaryInterface;
            TP_SOCKET_IFNAME = ic.primaryInterface;
            UCX_NET_DEVICES = ic.primaryInterface;
            NCCL_IB_HCA = lib.concatStringsSep "," ic.rdmaDevices;
            NCCL_IB_DISABLE = "0";
            NCCL_IGNORE_CPU_AFFINITY = "1";
            NCCL_DEBUG = "WARN";
            PYTORCH_CUDA_ALLOC_CONF = "expandable_segments:True";
          }
          // cfg.environment;
          cmd = [ "vllm" ] ++ serveArgs;
        };

        systemd.services.${serviceName} = {
          after = [
            "nvidia-container-toolkit-cdi-generator.service"
            "network-addresses-${ic.primaryInterface}.service"
          ];
          wants = [ "nvidia-container-toolkit-cdi-generator.service" ];
          serviceConfig = {
            ExecStartPre = lib.mkBefore [
              # See the resync units below.
              "${pokePeers}"
              # Drop page caches so vLLM sees the whole unified memory pool.
              "${pkgs.bash}/bin/bash -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"
            ];
            Restart = lib.mkForce "always";
            RestartSec = 10;
          };
        };

        # Restart=always is not enough to keep the ranks paired. When one rank
        # dies (a GPU Xid took the head down on 2026-10-02), the survivor does
        # not exit: it keeps its half of the model and loops on NCCL heartbeat
        # errors, and the restarted rank times out at the rendezvous waiting
        # for a partner that is still attached to the dead group. The cluster
        # then stays down until someone restarts the survivor by hand.
        #
        # So every rank, each time it starts, asks its peers over the cable
        # to restart theirs, and a rank that only just started declines. One
        # crash anywhere becomes one coordinated restart everywhere.
        systemd.sockets.vllm-cluster-resync = {
          description = "Resync requests from vLLM cluster peers";
          wantedBy = [ "sockets.target" ];
          listenStreams = [ "${hostIp}:${toString cfg.resyncPort}" ];
          socketConfig = {
            Accept = true;
            # The interconnect address may not be configured yet at boot.
            FreeBind = true;
          };
        };
        systemd.services."vllm-cluster-resync@" = {
          description = "Restart the local vLLM rank on a peer's request";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${resync}";
          };
        };
      }
    ]
  );
}
