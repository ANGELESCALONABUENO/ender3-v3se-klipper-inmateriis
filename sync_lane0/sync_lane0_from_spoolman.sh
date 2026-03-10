#!/usr/bin/env bash
set -euo pipefail

MOONRAKER_URL="http://127.0.0.1:7125"
SPOOLMAN_URL="http://192.168.1.156:7912"
CURL_OPTS=(--max-time 6 -s)

# Get active spool id from Moonraker's spoolman component
active_spool_id="$(curl "${CURL_OPTS[@]}" "$MOONRAKER_URL/server/spoolman/status" | sed -n 's/.*"spool_id":\([0-9-]*\).*/\1/p')"
if [[ -z "${active_spool_id}" || "${active_spool_id}" == "-1" ]]; then
  echo "No active spool_id reported by Moonraker"
  exit 1
fi

# Fetch spool details from remote Spoolman
spool_json="$(curl "${CURL_OPTS[@]}" "$SPOOLMAN_URL/api/v1/spool/$active_spool_id")"

# Parse with Python to avoid brittle regex parsing
readarray -t parsed < <(
  python3 - <<'PY' "$spool_json"
import json
import sys

data = json.loads(sys.argv[1])
f = data.get("filament", {})
vendor = f.get("vendor", {})

print(f.get("material") or "")
print(f.get("name") or "")
print(vendor.get("name") or "")
print(f.get("color_hex") or "")
print(str(f.get("id") or ""))
print(str(f.get("settings_extruder_temp") or ""))
print(str(f.get("settings_bed_temp") or ""))
print(str(data.get("remaining_weight") or ""))
PY
)

material="${parsed[0]:-}"
name="${parsed[1]:-}"
vendor="${parsed[2]:-}"
color_hex="${parsed[3]:-}"
filament_id="${parsed[4]:-}"
nozzle_temp="${parsed[5]:-}"
bed_temp="${parsed[6]:-}"
remaining_g="${parsed[7]:-}"

# Reasonable fallbacks
vendor="${vendor:-Unknown}"
name="${name:-Spool ${active_spool_id}}"
material="${material:-PLA}"
color_hex="${color_hex:-ffffff}"
filament_id="${filament_id:-0}"
nozzle_temp="${nozzle_temp:-200}"
bed_temp="${bed_temp:-60}"
remaining_g="${remaining_g:-0}"

# Normalize to compact numeric values for gcode params.
nozzle_temp="$(printf '%.1f' "$nozzle_temp")"
bed_temp="$(printf '%.1f' "$bed_temp")"
remaining_g="$(printf '%.1f' "$remaining_g")"

payload=$(cat <<JSON
{
  "namespace": "lane_data",
  "key": "lane0",
  "value": {
    "vendor_name": "$vendor",
    "name": "$name",
    "color": "$color_hex",
    "material": "$material",
    "bed_temp": $bed_temp,
    "nozzle_temp": $nozzle_temp,
    "scan_time": null,
    "td": null,
    "lane": "0",
    "spool_id": $active_spool_id,
    "filament_id": $filament_id
  }
}
JSON
)

curl "${CURL_OPTS[@]}" -X POST "$MOONRAKER_URL/server/database/item" \
  -H 'Content-Type: application/json' \
  -d "$payload" >/dev/null

# Persist temperatures in Moonraker DB used by [save_variables].
vars_payload=$(cat <<JSON
{
  "namespace": "klipper",
  "key": "variables",
  "value": {
    "spoolman_nozzle_temp": $nozzle_temp,
    "spoolman_bed_temp": $bed_temp
  }
}
JSON
)
curl "${CURL_OPTS[@]}" -X POST "$MOONRAKER_URL/server/database/item" \
  -H 'Content-Type: application/json' \
  -d "$vars_payload" >/dev/null || true

# Optional live update (can hang on some setups while printer is busy).
sync_cmd="SYNC_SPOOLMAN_NOW NOZZLE=$nozzle_temp BED=$bed_temp REMAINING_G=$remaining_g"
for attempt in 1 2 3; do
  if curl --max-time 12 -sS -X POST "$MOONRAKER_URL/printer/gcode/script" \
    -H 'Content-Type: application/json' \
    -d "{\"script\":\"$sync_cmd\"}" >/dev/null; then
    break
  fi
  sleep 1
done

# Single-extruder mode: keep only lane0 visible to Orca sync logic.
for i in $(seq 1 15); do
  curl "${CURL_OPTS[@]}" -X DELETE "$MOONRAKER_URL/server/database/item?namespace=lane_data&key=lane$i" >/dev/null || true
done

echo "lane0 synced to spool_id=$active_spool_id ($material, $name) temps: nozzle=$nozzle_temp bed=$bed_temp remaining_g=$remaining_g"
