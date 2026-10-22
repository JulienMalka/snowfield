# TP-7 takes become messages to Jacques. Each new WAV tp7-sync drops is
# uploaded to the agentic-workflows bucket under tp7_notes/inbox/, then the
# Windmill flow f/tp7_notes/process_note is started on it: it transcribes,
# corrects and posts the text to Jacques' webhook route on jacques.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.services.tp7-sync.settings) destination;

  # tp7-sync copies everything still on the device, one file at a time, so
  # old takes arrive alongside new ones and each triggers its own pass.
  # Only takes recorded this recently are sent; older ones are marked as
  # seen and left alone. The recorder names its files after the local time
  # it started recording, e.g. 2026-10-22_142204_000.wav; other files go by
  # their modification time.
  maxAge = 12 * 3600;

  upload = pkgs.writeShellApplication {
    name = "tp7-notes";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      findutils
      jq
    ];
    text = ''
      sent="$STATE_DIRECTORY/sent"
      takes() {
        { find ${destination} -type f -iname '*.wav' -printf '%P\n' 2> /dev/null || true; } | LC_ALL=C sort
      }

      if [ ! -e "$sent" ]; then
        takes > "$sent"
        echo "first run: $(wc -l < "$sent") existing takes marked as seen"
        exit 0
      fi

      recorded() {
        local name
        name="$(basename "$1")"
        if [[ "$name" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2}) ]]; then
          date -d "''${BASH_REMATCH[1]} ''${BASH_REMATCH[2]}:''${BASH_REMATCH[3]}:''${BASH_REMATCH[4]}" +%s
        else
          date -r "$1" +%s
        fi
      }

      mapfile -t new < <(takes | LC_ALL=C comm -23 - <(LC_ALL=C sort "$sent"))

      set -a
      # shellcheck disable=SC1091
      . ${config.age.secrets.tp7-notes.path}
      set +a

      for take in "''${new[@]}"; do
        path="${destination}/$take"
        if [ $(($(date +%s) - $(recorded "$path"))) -gt ${toString maxAge} ]; then
          echo "$take: recorded more than ${toString maxAge}s ago, not sent"
          printf '%s\n' "$take" >> "$sent"
          continue
        fi
        key="inbox/$(date -r "$path" +%Y%m%dT%H%M%S)-$(basename "$take" | tr -c 'A-Za-z0-9._\n-' _)"
        curl -fsS --aws-sigv4 aws:amz:paris:s3 \
          --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
          -T "$path" "https://s3.luj.fr/agentic-workflows/tp7_notes/$key"
        job="$(
          jq -n --arg key "$key" --arg synced_at "$(date -r "$path" -Iseconds)" \
            '{key: $key, synced_at: $synced_at}' |
            curl -fsS -H "Authorization: Bearer $WINDMILL_TOKEN" \
              -H 'Content-Type: application/json' --data-binary @- \
              https://workflows.luj.fr/api/w/ai-workflows/jobs/run/f/f/tp7_notes/process_note
        )"
        echo "$take -> tp7_notes/$key, job $job"
        printf '%s\n' "$take" >> "$sent"
      done
    '';
  };
in
{
  # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY of the Garage key
  # tp7-gallifrey, and WINDMILL_TOKEN, a token scoped to
  # jobs:run:flows:f/tp7_notes/process_note, as shell assignments.
  age.secrets.tp7-notes = {
    file = ./secrets/tp7-notes.age;
    owner = "julien";
    mode = "0400";
  };

  systemd.user.services.tp7-notes = {
    description = "Send new TP-7 takes to Jacques";
    # A sync renames files in quick succession and each one starts a pass;
    # the default start limit failed the path unit halfway through one.
    startLimitIntervalSec = 0;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe upload;
      StateDirectory = "tp7-notes";
    };
  };

  # tp7-sync renames each finished copy into place, so a directory change
  # means a complete file. The timer retries whatever failed to go out.
  systemd.user.paths.tp7-notes = {
    wantedBy = [ "default.target" ];
    pathConfig = {
      PathChanged = [
        destination
        "${destination}/recordings"
      ];
      MakeDirectory = true;
    };
  };

  systemd.user.timers.tp7-notes = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitInactiveSec = "15min";
    };
  };
}
