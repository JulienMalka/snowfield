{
  config,
  lib,
  pkgs,
  ...
}:
let
  caConfig = import ../lib/ca-config.nix;
  hasVPN = lib.hasAttrByPath [ "vpn" "ipv4" ] config.machine.meta.ips;
in
{
  services.openssh = {
    enable = true;
    ports = [ 45 ];
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "yes";
    openFirewall = true;
  };

  environment.etc."ssh/ssh_user_key.pub" = lib.mkIf hasVPN {
    text = caConfig.sshUserCAPublicKey;
  };

  environment.etc."step/certs/root_ca.crt" = lib.mkIf hasVPN {
    text = caConfig.rootCAPem;
  };

  services.openssh.extraConfig = lib.mkIf hasVPN ''
    TrustedUserCAKeys /etc/ssh/ssh_user_key.pub
    HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
    HostKey /etc/ssh/ssh_host_ed25519_key
    MaxAuthTries 20
  '';

  age.secrets.step-ca-jwk-password = lib.mkIf hasVPN {
    file = ./step-ca-jwk-password.age;
  };

  systemd.services.ssh-host-cert-renew = lib.mkIf hasVPN {
    description = "Renew SSH host certificate from step-ca";
    path = [ pkgs.step-cli ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    script = ''
      step ssh certificate \
        "${config.networking.hostName}.luj" \
        /etc/ssh/ssh_host_ed25519_key.pub \
        --host \
        --sign \
        --provisioner "ssh-host-provisioner" \
        --provisioner-password-file ${config.age.secrets.step-ca-jwk-password.path} \
        --ca-url ${caConfig.stepCAUrl} \
        --root /etc/step/certs/root_ca.crt \
        --force \
        --principal "${config.networking.hostName}" \
        --principal "${config.networking.hostName}.luj"

      ${pkgs.systemd}/bin/systemctl reload sshd.service || true
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.ssh-host-cert-renew = lib.mkIf hasVPN {
    description = "Periodic SSH host certificate renewal";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnCalendar = "weekly";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
