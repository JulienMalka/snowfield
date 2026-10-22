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

  # More new takes than this in one pass is the recorder's backlog arriving
  # (tp7-sync copies everything still on the device), not someone talking to
  # Jacques. They are marked as seen and left alone.
  maxBatch = 3;

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

      mapfile -t new < <(takes | LC_ALL=C comm -23 - <(LC_ALL=C sort "$sent"))
      if [ "''${#new[@]}" -gt ${toString maxBatch} ]; then
        echo "''${#new[@]} new takes at once, treated as backlog and not sent"
        printf '%s\n' "''${new[@]}" >> "$sent"
        exit 0
      fi

      set -a
      # shellcheck disable=SC1091
      . ${config.age.secrets.tp7-notes.path}
      set +a

      for take in "''${new[@]}"; do
        path="${destination}/$take"
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
