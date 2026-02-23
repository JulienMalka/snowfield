{
  lib,
  config,
  ...
}:

let
  cfg = config.services.backup;
  # We backup on gustave
  host = "gustave.luj";
  port = "45";
  hostPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJrHUzjPX0v2FX5gJALCjEJaUJ4sbfkv8CBWc6zm0Oe";
  sshKey = config.age.secrets."borg-ssh-key".path;
  secretPath = config.age.secrets."borg-encryption-secret".path;

in
{
  options.services.backup =
    with lib;
    with types;
    {
      quota = mkOption {
        type = nullOr str;
        default = null;
        example = "90G";
        description = ''
          Quota for the borg repository. Useful to prevent the target disk from running full and ensuring borg keeps some space to work with.
        '';
      };

      includes = mkOption {
        type = listOf path;
        default = [ ];
        description = ''
          Paths to include in the backup.
        '';
      };

      excludes = mkOption {
        type = listOf path;
        default = [ ];
        description = ''
          Paths to exclude in the backup.
        '';
      };

      preHook = mkOption {
        type = lines;
        default = "";
        description = ''
          Shell commands to run before the backup.
        '';
      };

      postHook = mkOption {
        type = lines;
        default = "";
        description = ''
          Shell commands to run after the backup.
        '';
      };

      wantedUnits = mkOption {
        type = listOf str;
        default = [ ];
        description = ''
          List of units to require before starting the backup.
        '';
      };
    };

  config = lib.mkIf (cfg.includes != [ ]) {

    age.secrets."borg-ssh-key" = {
      file = ./borg-ssh-priv.age;
      owner = "root";
      mode = "0600";
    };

    age.secrets."borg-encryption-secret".file = ./borg-encryption-secret.age;

    programs.ssh.knownHosts."${if port != 22 then "[${host}]:${port}" else host}" = {
      publicKey = "${hostPublicKey}";
    };

    systemd.services.borgbackup-job-state = {
      wants = cfg.wantedUnits;
      after = cfg.wantedUnits;
    };

    systemd.timers.borgbackup-job-state.timerConfig = {
      # Spread all backups over the day
      RandomizedDelaySec = "30m";
      FixedRandomDelay = true;
    };

    services.borgbackup.jobs.state = {
      inherit (cfg) preHook postHook;

      # Create the repo
      doInit = true;

      # Create daily backups, but prune to a reasonable amount
      startAt = [ "hourly" ];
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 3;
      };

      # What to backup
      paths = cfg.includes;
      exclude = cfg.excludes;

      # Where to backup it to
      repo = "borg@gustave.luj:${config.networking.hostName}";
      environment.BORG_RSH = "ssh -p ${port} -i ${sshKey}";

      # Ensure we don't fill up the destination disk
      extraInitArgs = lib.optionalString (cfg.quota != null) "--storage-quota ${cfg.quota}";

      # Authenticated & encrypted, key resides in the repository
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${secretPath}";
      };

      # Reduce the backup size
      compression = "auto,zstd";

      # Show summary detailing data usage once completed
      extraCreateArgs = "--stats";
    };
  };
}
