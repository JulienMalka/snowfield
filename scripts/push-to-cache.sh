#!/usr/bin/env bash
set -euo pipefail
export LC_NUMERIC=C

PARALLEL=${PARALLEL:-32}

if [ -z "${STORE_ENDPOINT:-}" ] || [ -z "${STORE_USER:-}" ]; then
  echo "push-to-cache: STORE_ENDPOINT or STORE_USER not set, skipping" >&2
  exit 0
fi

if [ -z "${STORE_PASSWORD:-}" ]; then
  echo "push-to-cache: STORE_PASSWORD not set" >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "usage: push-to-cache <store-path>..." >&2
  exit 1
fi

# --- setup netrc ---
NETRC=$(mktemp)
cleanup() { rm -f "$NETRC"; }
trap cleanup EXIT

host=$(echo "$STORE_ENDPOINT" | sed 's|https\?://||;s|/.*||')
cat > "$NETRC" <<EOF
machine $host
login $STORE_USER
password $STORE_PASSWORD
EOF
chmod 600 "$NETRC"

CACHE_URL="${STORE_ENDPOINT}?compression=none"

# --- formatting helpers ---
bold=$'\033[1m'
dim=$'\033[2m'
green=$'\033[32m'
yellow=$'\033[33m'
reset=$'\033[0m'

human_size() {
  local bytes=$1
  if [ "$bytes" -ge 1073741824 ]; then
    printf "%.1f GiB" "$(echo "$bytes / 1073741824" | bc -l)"
  elif [ "$bytes" -ge 1048576 ]; then
    printf "%.1f MiB" "$(echo "$bytes / 1048576" | bc -l)"
  elif [ "$bytes" -ge 1024 ]; then
    printf "%.1f KiB" "$(echo "$bytes / 1024" | bc -l)"
  else
    printf "%d B" "$bytes"
  fi
}

human_speed() {
  local bytes=$1 secs=$2
  if [ "$secs" = "0" ]; then
    echo "-.-- MiB/s"
    return
  fi
  local bps
  bps=$(echo "$bytes / $secs" | bc -l)
  if [ "$(echo "$bps >= 1073741824" | bc)" -eq 1 ]; then
    printf "%.1f GiB/s" "$(echo "$bps / 1073741824" | bc -l)"
  elif [ "$(echo "$bps >= 1048576" | bc)" -eq 1 ]; then
    printf "%.1f MiB/s" "$(echo "$bps / 1048576" | bc -l)"
  else
    printf "%.1f KiB/s" "$(echo "$bps / 1024" | bc -l)"
  fi
}

# strip /nix/store/<32-char-hash>- prefix, keep the package name
path_name() {
  local base
  base=$(basename "$1")
  echo "${base:33}"
}

# --- enumerate closure ---
echo "${bold}Enumerating closure...${reset}"
mapfile -t all_paths < <(nix path-info --extra-experimental-features nix-command -r "$@" 2>/dev/null)
total=${#all_paths[@]}
echo "  ${total} paths in closure"
echo

# --- check which paths are already cached (parallel) ---
echo "${bold}Checking remote cache (${PARALLEL} parallel)...${reset}"
cached_list=$(mktemp)

check_one() {
  local p=$1 netrc=$2 endpoint=$3
  local hash
  hash=$(basename "$p" | cut -c1-32)
  status=$(curl -sS -o /dev/null -w "%{http_code}" --netrc-file "$netrc" "${endpoint}/${hash}.narinfo" 2>/dev/null) || true
  if [ "$status" = "200" ]; then
    echo "$p"
  fi
}
export -f check_one

printf '%s\n' "${all_paths[@]}" \
  | xargs -P "$PARALLEL" -I{} bash -c 'check_one "$@"' _ {} "$NETRC" "$STORE_ENDPOINT" \
  > "$cached_list"

already_cached=$(wc -l < "$cached_list")

# build the to_upload list by diffing
mapfile -t to_upload < <(comm -23 <(printf '%s\n' "${all_paths[@]}" | sort) <(sort "$cached_list"))
rm -f "$cached_list"

upload_count=${#to_upload[@]}
echo "  ${green}${already_cached} already in cache${reset}"
echo "  ${yellow}${upload_count} to upload${reset}"
echo

if [ "$upload_count" -eq 0 ]; then
  echo "${green}${bold}Nothing to upload, cache is up to date.${reset}"
  exit 0
fi

# --- compute sizes in one batch ---
total_bytes=0
declare -A path_sizes
while IFS=$'\t' read -r p sz; do
  sz=${sz:-0}
  path_sizes["$p"]=$sz
  total_bytes=$((total_bytes + sz))
done < <(nix path-info --extra-experimental-features nix-command -s "${to_upload[@]}" 2>/dev/null | awk '{print $1 "\t" $2}')

echo "${bold}Uploading ${upload_count} paths ($(human_size $total_bytes))${reset}"
echo

# --- upload one by one ---
uploaded_bytes=0
failures=0
i=0

for p in "${to_upload[@]}"; do
  i=$((i + 1))
  sz=${path_sizes["$p"]:-0}
  name=$(path_name "$p")
  printf "${dim}[%d/%d]${reset} %s ${dim}(%s)${reset} " "$i" "$upload_count" "$name" "$(human_size "$sz")"

  start_ts=$(date +%s%N)
  if nix copy --extra-experimental-features nix-command \
       --to "$CACHE_URL" --netrc-file "$NETRC" "$p" 2>/dev/null; then
    end_ts=$(date +%s%N)
    elapsed_s=$(echo "($end_ts - $start_ts) / 1000000000" | bc -l)
    uploaded_bytes=$((uploaded_bytes + sz))
    printf "${green}done${reset} ${dim}%s${reset}\n" "$(human_speed "$sz" "$elapsed_s")"
  else
    failures=$((failures + 1))
    printf "${yellow}failed${reset}\n"
  fi
done

echo
echo "${bold}Summary:${reset} uploaded $(human_size $uploaded_bytes), ${failures} failures"
if [ "$failures" -gt 0 ]; then
  exit 1
fi
