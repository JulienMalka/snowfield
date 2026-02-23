{
  writeShellApplication,
  jq,
  openssh,
  nix,
  git,
  gh,
  coreutils,
  gnugrep,
  gnused,
}:

writeShellApplication {
  name = "snowfield";

  runtimeInputs = [
    jq
    openssh
    nix
    git
    gh
    coreutils
    gnugrep
    gnused
  ];

  excludeShellChecks = [
    "SC2034" # color vars referenced in printf
  ];

  text = ''
    repo_root="$(git rev-parse --show-toplevel)"

    # Work directory (cleaned up on exit)
    workdir=""
    cleanup() { if [[ -n "$workdir" ]]; then rm -rf "$workdir"; fi; }
    trap cleanup EXIT
    workdir=$(mktemp -d)

    # Colors
    RED=$'\033[0;31m'
    YELLOW=$'\033[0;33m'
    GREEN=$'\033[0;32m'
    BOLD=$'\033[1m'
    DIM=$'\033[2m'
    NC=$'\033[0m'

    usage() {
      echo "Usage: snowfield <command>"
      echo ""
      echo "Commands:"
      echo "  status    Show NixOS version and nixpkgs drift for all machines"
      echo ""
      echo "Options:"
      echo "  --help    Show this help message"
    }

    # Get commit date (YYYYMMDD) for a nixpkgs revision via GitHub API
    # Tries gh first (authenticated), falls back to curl (unauthenticated)
    nixpkgs_commit_date() {
      local rev="$1"
      local iso_date=""
      iso_date=$(gh api "repos/nixos/nixpkgs/commits/$rev" --jq '.commit.committer.date' 2>/dev/null) \
        || iso_date=$(curl -sf "https://api.github.com/repos/nixos/nixpkgs/commits/$rev" 2>/dev/null | jq -r '.commit.committer.date // empty') \
        || true
      if [[ -n "$iso_date" ]]; then
        date -d "$iso_date" "+%Y%m%d" 2>/dev/null || true
      fi
    }

    # Convert YYYYMMDD to epoch seconds
    date_to_epoch() {
      local d="$1"
      date -d "''${d:0:4}-''${d:4:2}-''${d:6:2}" +%s 2>/dev/null || echo ""
    }

    # Format YYYYMMDD as YYYY-MM-DD (fixed width, locale-independent)
    format_date() {
      local d="$1"
      if [[ -z "$d" ]]; then echo "-"; return; fi
      echo "''${d:0:4}-''${d:4:2}-''${d:6:2}"
    }

    # Compute drift in days between two YYYYMMDD dates
    compute_drift() {
      local deployed="$1" upstream="$2"
      if [[ -z "$deployed" || -z "$upstream" ]]; then echo "-"; return; fi

      local dep_epoch ups_epoch
      dep_epoch=$(date_to_epoch "$deployed")
      ups_epoch=$(date_to_epoch "$upstream")
      if [[ -z "$dep_epoch" || -z "$ups_epoch" ]]; then echo "-"; return; fi

      local diff=$(( (ups_epoch - dep_epoch) / 86400 ))
      if (( diff <= 0 )); then echo "up to date"
      elif (( diff == 1 )); then echo "1 day"
      else echo "$diff days"
      fi
    }

    # Print a value with color, padded to a given width
    # Usage: color_pad <width> <color> <text>
    color_pad() {
      local width="$1" color="$2" text="$3"
      printf '%s%-*s%s' "$color" "$width" "$text" "$NC"
    }

    # Print drift with color, padded to given width
    print_drift() {
      local width="$1" drift="$2"
      case "$drift" in
        "up to date") color_pad "$width" "$GREEN" "$drift" ;;
        "-")          color_pad "$width" "$DIM" "$drift" ;;
        *)
          local days
          days=$(grep -oP '\d+' <<< "$drift" || echo "0")
          if (( days <= 14 )); then
            color_pad "$width" "$YELLOW" "$drift"
          else
            color_pad "$width" "$RED" "$drift"
          fi
          ;;
      esac
    }

    # Extract the snowfield git rev from a NixOS system store path
    # e.g. /nix/store/...-nixos-system-core-security-25.11-c45c942-dirty → c45c942
    extract_snowfield_rev() {
      local path="$1"
      # Remove -dirty suffix
      local clean="''${path%-dirty}"
      # The rev is the last dash-separated segment
      local rev="''${clean##*-}"
      echo "$rev"
    }

    # Get the nixpkgs revision from lon.lock at a given snowfield commit
    # $1 = snowfield short rev, $2 = channel ("stable" or "unstable")
    get_deployed_nixpkgs_rev() {
      local sf_rev="$1" channel="$2"
      local input_name
      if [[ "$channel" == "stable" ]]; then
        input_name="nixpkgs"
      else
        input_name="unstable"
      fi
      git -C "$repo_root" show "''${sf_rev}:lon.lock" 2>/dev/null \
        | jq -r --arg name "$input_name" '.sources[$name].revision // empty' 2>/dev/null \
        || true
    }

    cmd_status() {
      local meta="$workdir/meta.json"
      local ssh_dir="$workdir/ssh"
      mkdir -p "$ssh_dir"

      # Step 1: Evaluate machine metadata locally
      printf '%s%s%s\n' "$DIM" "Evaluating machine metadata..." "$NC" >&2
      if ! nix-instantiate --eval --strict --json "$repo_root/scripts/machines-meta.nix" > "$meta" 2>/dev/null; then
        echo "Error: failed to evaluate machine metadata" >&2
        return 1
      fi

      # Step 2: Fetch upstream branch HEAD dates via GitHub API
      printf '%s%s%s\n' "$DIM" "Fetching upstream nixpkgs dates..." "$NC" >&2

      local branches
      branches=$(jq -r '[.[].branch] | unique | .[]' < "$meta")

      declare -A upstream_dates
      for branch in $branches; do
        [[ "$branch" == "unknown" ]] && continue
        local ud
        ud=$(nixpkgs_commit_date "$branch")
        if [[ -n "$ud" ]]; then
          upstream_dates["$branch"]="$ud"
        fi
      done

      # Display upstream info header
      echo ""
      for branch in $branches; do
        [[ "$branch" == "unknown" ]] && continue
        local ud="''${upstream_dates[$branch]:-}"
        if [[ -n "$ud" ]]; then
          printf '%sUpstream %s:%s  %s\n' "$BOLD" "$branch" "$NC" "$(format_date "$ud")"
        fi
      done
      echo ""

      # Step 3: Parallel SSH to all machines — get current-system store path
      printf '%s%s%s\n' "$DIM" "Connecting to machines..." "$NC" >&2

      local machines
      machines=$(jq -r 'keys[]' < "$meta" | sort)

      local -a bg_pids=()

      for machine in $machines; do
        local host port
        host=$(jq -r --arg m "$machine" '.[$m].ssh.host // empty' < "$meta")
        port=$(jq -r --arg m "$machine" '.[$m].ssh.port // 45' < "$meta")

        if [[ -z "$host" || "$host" == "null" ]]; then
          echo "unreachable" > "$ssh_dir/$machine"
          continue
        fi

        (
          ssh -p "$port" \
            -o ConnectTimeout=5 \
            -o BatchMode=yes \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o LogLevel=ERROR \
            "root@$host" 'readlink /run/current-system' > "$ssh_dir/$machine" 2>/dev/null \
          || echo "unreachable" > "$ssh_dir/$machine"
        ) &
        bg_pids+=($!)
      done

      # Wait for all SSH processes
      for pid in "''${bg_pids[@]}"; do
        wait "$pid" 2>/dev/null || true
      done

      # Step 4: For each machine, extract snowfield rev and look up deployed nixpkgs
      printf '%s%s%s\n' "$DIM" "Resolving deployed versions..." "$NC" >&2

      # Cache: snowfield rev + channel → nixpkgs commit date
      declare -A nixpkgs_date_cache

      # Column format: Machine(17) Channel(10) SF Rev(10) Nixpkgs(10) Deployed(12) Upstream(12) Drift(12)
      local fmt="%-17s %-10s %-10s %-10s %-12s %-12s %s\n"

      printf '\n'
      printf "%s$fmt%s" "$BOLD" "Machine" "Channel" "SF Rev" "Nixpkgs" "Deployed" "Upstream" "Drift" "$NC"
      printf '%s\n' "─────────────────────────────────────────────────────────────────────────────────────"

      for machine in $machines; do
        local channel branch
        channel=$(jq -r --arg m "$machine" '.[$m].channel' < "$meta")
        branch=$(jq -r --arg m "$machine" '.[$m].branch' < "$meta")

        local store_path=""
        if [[ -f "$ssh_dir/$machine" ]]; then
          store_path=$(tr -d '[:space:]' < "$ssh_dir/$machine")
        fi

        local ud="''${upstream_dates[$branch]:-}"

        # Unreachable
        if [[ -z "$store_path" || "$store_path" == "unreachable" ]]; then
          printf '%-17s %-10s %-10s %-10s %-12s %-12s %s\n' \
            "$machine" "$channel" "-" "-" "-" "$(format_date "$ud")" "$(print_drift 12 "-")"
          continue
        fi

        # Extract snowfield rev from store path
        local sf_rev
        sf_rev=$(extract_snowfield_rev "$store_path")

        if [[ -z "$sf_rev" ]]; then
          printf '%-17s %-10s %-10s %-10s %-12s %-12s %s\n' \
            "$machine" "$channel" "?" "-" "-" "$(format_date "$ud")" "$(print_drift 12 "-")"
          continue
        fi

        # Look up deployed nixpkgs revision (cached per sf_rev+channel)
        local cache_key="''${sf_rev}:''${channel}"
        local deployed_date="''${nixpkgs_date_cache[$cache_key]:-}"

        if [[ -z "$deployed_date" ]]; then
          local nixpkgs_rev
          nixpkgs_rev=$(get_deployed_nixpkgs_rev "$sf_rev" "$channel")
          if [[ -n "$nixpkgs_rev" ]]; then
            deployed_date=$(nixpkgs_commit_date "$nixpkgs_rev")
            if [[ -n "$deployed_date" ]]; then
              nixpkgs_date_cache["$cache_key"]="$deployed_date"
            fi
          fi
        fi

        local short_nixpkgs
        short_nixpkgs=$(get_deployed_nixpkgs_rev "$sf_rev" "$channel")
        short_nixpkgs="''${short_nixpkgs:0:7}"

        local drift
        drift=$(compute_drift "$deployed_date" "$ud")

        printf '%-17s %-10s %-10s %-10s %-12s %-12s %s\n' \
          "$machine" "$channel" "$sf_rev" "''${short_nixpkgs:--}" "$(format_date "$deployed_date")" "$(format_date "$ud")" "$(print_drift 12 "$drift")"
      done
    }

    case "''${1:-}" in
      status)  cmd_status ;;
      --help|-h|"") usage ;;
      *)
        echo "Unknown command: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  '';
}
