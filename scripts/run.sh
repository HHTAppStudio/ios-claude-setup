#!/usr/bin/env bash
# Run wrapper — build, cài và mở app trên simulator RIÊNG của worktree,
# chụp screenshot + thu log runtime để kiểm tra app chạy thật (không chỉ compile).
# Usage: ./scripts/run.sh [extra xcodebuild args...]
source "$(dirname "$0")/_common.sh"

CONTAINER_LINE="$(detect_container)"
IFS='|' read -r FLAG CONTAINER <<< "$CONTAINER_LINE"
if [ "$FLAG" = "-spm" ]; then
  echo "ERROR: /run cần app target (.xcodeproj/.xcworkspace) — Swift package không chạy được trên simulator." >&2
  exit 1
fi
SCHEME_NAME="$(detect_scheme)"
require_scheme "$SCHEME_NAME"
TS="$(date +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/run-$TS.log"

SIM_UDID="$(ensure_sim)" || exit 1
# Boot nếu chưa boot, đợi sẵn sàng
xcrun simctl bootstatus "$SIM_UDID" -b >/dev/null

echo "Building '$SCHEME_NAME' cho simulator → log: $LOG"
set +e
set -o pipefail
xcodebuild "$FLAG" "$CONTAINER" \
  -scheme "$SCHEME_NAME" \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  -quiet \
  build "$@" 2>&1 | tee "$LOG" | filter_xcode_log
STATUS=${PIPESTATUS[0]}
set -e
if [ "$STATUS" -ne 0 ]; then
  echo "BUILD FAILED (exit $STATUS). Full log: $LOG"
  grep -E "error:" "$LOG" | sort -u | head -20 || true
  exit "$STATUS"
fi

# Products/ chứa cả app LẪN runner của UITests ("<Scheme>UITests-Runner.app",
# bundle id "…UITests.xctrunner"). Thứ tự `find` là thứ tự thư mục chứ không
# sắp xếp, nên `| head -1` có lúc bốc trúng runner: /run cài + launch runner,
# app thật không bao giờ chạy và screenshot ra màn hình Home. Ưu tiên .app
# trùng tên scheme, fallback thì loại hẳn runner/test bundle.
APP_PATH=""
for CANDIDATE in "$DERIVED_DATA/Build/Products"/*-iphonesimulator/"$SCHEME_NAME.app"; do
  [ -d "$CANDIDATE" ] && { APP_PATH="$CANDIDATE"; break; }
done
# PRODUCT_NAME có thể khác tên scheme — khi đó dò tìm, trừ runner ra.
[ -n "$APP_PATH" ] || APP_PATH=$(find "$DERIVED_DATA/Build/Products" -maxdepth 2 -name "*.app" -path "*iphonesimulator*" \
  ! -name "*-Runner.app" ! -name "*Tests.app" 2>/dev/null | head -1)
[ -n "$APP_PATH" ] || { echo "ERROR: không tìm thấy .app trong $DERIVED_DATA/Build/Products (scheme có phải app target?)" >&2; exit 1; }
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Info.plist")

open -a Simulator >/dev/null 2>&1 || true
xcrun simctl install "$SIM_UDID" "$APP_PATH"
xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" >/dev/null

# Đợi app render rồi chụp màn hình
WAIT="${RUN_WAIT_SECONDS:-3}"
sleep "$WAIT"
SHOT="$LOG_DIR/run-$TS.png"
xcrun simctl io "$SIM_UDID" screenshot "$SHOT" >/dev/null 2>&1 || true

# Thu log runtime của app (crash, console) trong 1 phút gần nhất
APP_NAME="$(basename "$APP_PATH" .app)"
xcrun simctl spawn "$SIM_UDID" log show --last 1m \
  --predicate "processImagePath ENDSWITH \"$APP_NAME\"" >> "$LOG" 2>/dev/null || true

echo ""
echo "✓ App $BUNDLE_ID đang chạy trên simulator riêng của worktree"
[ -f "$SHOT" ] && echo "  Screenshot: $SHOT   ← đọc file này để kiểm tra UI"
echo "  Runtime log: $LOG"
if grep -qE "Fatal error|Terminating app due to|=== CRASH ===" "$LOG"; then
  echo "⚠ Dấu hiệu crash trong runtime log:"
  grep -E "Fatal error|Terminating app due to|=== CRASH ===" "$LOG" | head -5
  exit 1
fi
