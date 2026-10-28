#!/bin/bash
# usage: run.sh file.lua   (or stdin) -> sends to REAPER bridge, waits for result
D="$(cd "$(dirname "$0")" && pwd)"
ID="-- id $(date +%s%N)"
BODY=$(cat "${1:-/dev/stdin}")
printf "%s\n%s\n" "$ID" "$BODY" > "$D/cmd.lua.tmp" && mv "$D/cmd.lua.tmp" "$D/cmd.lua"
for i in $(seq 1 100); do
  if head -1 "$D/out.txt" 2>/dev/null | grep -qF -- "$ID"; then tail -n +2 "$D/out.txt"; exit 0; fi
  sleep 0.2
done
echo "TIMEOUT"
