#!/usr/bin/env bash
# Build wrapper — ghi full log ra file, chỉ in lỗi/cảnh báo ra stdout (tiết kiệm token).
# Usage: ./scripts/build.sh [extra xcodebuild args...]
source "$(dirname "$0")/_common.sh"

# Gán qua biến trung gian để lỗi trong detect_container dừng script (set -e
# không lan qua command substitution nằm trong `read <<< "$(...)"`).
CONTAINER_LINE="$(detect_container)"
IFS='|' read -r FLAG CONTAINER <<< "$CONTAINER_LINE"
LOG="$LOG_DIR/build-$(date +%Y%m%d-%H%M%S).log"

# Swift package thuần (không có xcodeproj/xcworkspace) → swift build
if [ "$FLAG" = "-spm" ]; then
  echo "Swift package — 'swift build' → log: $LOG"
  set +e
  set -o pipefail
  swift build --package-path "$ROOT" "$@" 2>&1 | tee "$LOG" | filter_swift_log
  STATUS=${PIPESTATUS[0]}
  set -e
  if [ "$STATUS" -eq 0 ]; then
    echo "BUILD SUCCEEDED"
  else
    echo "BUILD FAILED (exit $STATUS). Full log: $LOG"
    echo "--- Errors ---"
    grep -E "error:" "$LOG" | sort -u | head -30 || true
  fi
  exit "$STATUS"
fi

SCHEME_NAME="$(detect_scheme)"
require_scheme "$SCHEME_NAME"

echo "Building scheme '$SCHEME_NAME' → log: $LOG"
set +e
set -o pipefail
# Destination generic: chỉ compile, không đụng tới simulator cụ thể
# → nhiều worktree build song song không tranh nhau máy ảo.
xcodebuild "$FLAG" "$CONTAINER" \
  -scheme "$SCHEME_NAME" \
  -destination "${DESTINATION:-generic/platform=iOS Simulator}" \
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
  grep -E "error:" "$LOG" | sort -u | head -30 || true
fi
exit "$STATUS"
