#!/usr/bin/env bash
set -euo pipefail
export LC_NUMERIC=C

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

# --- get sizes for all paths in one batch ---
declare -A path_sizes
while IFS=$'\t' read -r p sz; do
  path_sizes["$p"]=${sz:-0}
done < <(nix path-info --extra-experimental-features nix-command -s "${all_paths[@]}" 2>/dev/null | awk '{print $1 "\t" $2}')

total_bytes=0
for sz in "${path_sizes[@]}"; do
  total_bytes=$((total_bytes + sz))
done
echo "  $(human_size $total_bytes) total"
echo

# --- check which paths are already cached ---
# Use the signing endpoint (public read) to check narinfo existence
SIGNING_URL="${STORE_ENDPOINT}.signing"
echo "${bold}Checking cache...${reset}"

check_narinfo() {
  local p=$1
  local hash
  hash=$(basename "$p" | cut -c1-32)
  local http_code attempt
  for attempt in 1 2 3; do
    http_code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 10 \
      "${SIGNING_URL}/${hash}.narinfo" 2>/dev/null) || http_code="000"
    # 200 = cached, 404 = not cached, anything else = retry
    if [ "$http_code" = "200" ]; then
      return
    elif [ "$http_code" = "404" ]; then
      echo "$p"
      return
    fi
    sleep 1
  done
  # after 3 retries, assume not cached
  echo "$p"
}
export -f check_narinfo
export SIGNING_URL

mapfile -t to_upload < <(printf '%s\n' "${all_paths[@]}" \
  | xargs -P 10 -I{} bash -c 'check_narinfo "$@"' _ {})

upload_count=${#to_upload[@]}
upload_bytes=0
for p in "${to_upload[@]}"; do
  upload_bytes=$((upload_bytes + ${path_sizes["$p"]:-0}))
done
cached_count=$((total - upload_count))

echo "  ${green}${cached_count}${reset} already cached"
echo "  ${bold}${upload_count}${reset} to upload ($(human_size $upload_bytes))"
echo

if [ "$upload_count" -eq 0 ]; then
  echo "${bold}Nothing to upload, all paths already cached.${reset}"
  exit 0
fi

# --- upload, letting nix copy handle dedup ---
echo "${bold}Pushing ${upload_count} paths ($(human_size $upload_bytes))...${reset}"
echo

uploaded=0
uploaded_bytes=0
start_ts=$(date +%s%N)
declare -A seen_paths

exec 3< <(nix copy --extra-experimental-features nix-command \
  --to "$CACHE_URL" --netrc-file "$NETRC" \
  -v "${to_upload[@]}" 2>&1; echo "EXIT:$?")

while IFS= read -r line <&3; do
  if [[ "$line" == EXIT:* ]]; then
    exit_code="${line#EXIT:}"
    break
  fi
  if [[ "$line" == *"copying path"* ]]; then
    path=$(echo "$line" | sed "s/.*'\(\/nix\/store\/[^']*\)'.*/\1/")
    if [ -n "$path" ] && [ -z "${seen_paths["$path"]+x}" ]; then
      seen_paths["$path"]=1
      uploaded=$((uploaded + 1))
      sz=${path_sizes["$path"]:-0}
      uploaded_bytes=$((uploaded_bytes + sz))
      name=$(path_name "$path")
      now_ts=$(date +%s%N)
      elapsed_s=$(echo "($now_ts - $start_ts) / 1000000000" | bc -l)
      speed=$(human_speed "$uploaded_bytes" "$elapsed_s")
      printf "${dim}[%d/%d]${reset} %s ${dim}(%s)${reset} ${green}done${reset} ${dim}%s avg${reset}\n" \
        "$uploaded" "$upload_count" "$name" "$(human_size "$sz")" "$speed"
    fi
  fi
done
exec 3<&-

end_ts=$(date +%s%N)
elapsed_s=$(echo "($end_ts - $start_ts) / 1000000000" | bc -l)

actual_cached=$((total - uploaded))

echo
if [ "${exit_code:-0}" -eq 0 ]; then
  echo "${bold}Summary:${reset} ${uploaded} uploaded ($(human_size $uploaded_bytes)), ${actual_cached} already cached"
  echo "  $(printf "%.0f" "$elapsed_s")s elapsed ($(human_speed "$uploaded_bytes" "$elapsed_s") avg)"
else
  echo "${yellow}${bold}Summary:${reset} upload failed (exit $exit_code), ${uploaded}/${upload_count} paths copied"
  exit 1
fi
