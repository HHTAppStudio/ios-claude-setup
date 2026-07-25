#!/usr/bin/env bash
# Build wrapper — ghi full log ra file, chỉ in lỗi/cảnh báo ra stdout (tiết kiệm token).
# Usage: ./scripts/build.sh [extra xcodebuild args...]
source "$(dirname "$0")/_common.sh"

IFS='|' read -r FLAG CONTAINER <<< "$(detect_container)"
SCHEME_NAME="$(detect_scheme)"
LOG="$LOG_DIR/build-$(date +%Y%m%d-%H%M%S).log"

echo "Building scheme '$SCHEME_NAME' → log: $LOG"
set +e
set -o pipefail
xcodebuild "$FLAG" "$CONTAINER" \
  -scheme "$SCHEME_NAME" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -quiet \
  build "$@" 2>&1 | tee "$LOG" | filter_xcode_log
STATUS=${PIPESTATUS[0]}
set -e

if [ "$STATUS" -eq 0 ]; then
  echo "BUILD SUCCEEDED"
else
  echo "BUILD FAILED (exit $STATUS). Full log: $LOG"
  echo "--- Errors ---"
  grep -E "error:" "$LOG" | sort -u | head -30
fi
exit "$STATUS"
