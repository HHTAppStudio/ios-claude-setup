#!/usr/bin/env bash
# Test wrapper — chỉ in kết quả tóm tắt và test fail (tiết kiệm token).
# Usage: ./scripts/test.sh [-only-testing:Target/Class/testMethod] [extra args...]
source "$(dirname "$0")/_common.sh"

CONTAINER_LINE="$(detect_container)"
IFS='|' read -r FLAG CONTAINER <<< "$CONTAINER_LINE"
SCHEME_NAME="$(detect_scheme)"
LOG="$LOG_DIR/test-$(date +%Y%m%d-%H%M%S).log"

# Test cần simulator cụ thể → dùng máy ảo RIÊNG của worktree này (tự tạo nếu chưa có)
# để nhiều worktree test song song không tranh nhau. DESTINATION trong ios.env (nếu đặt)
# sẽ override — khi đó bạn tự chịu trách nhiệm tránh trùng simulator giữa các worktree.
if [ -n "${DESTINATION:-}" ]; then
  TEST_DEST="$DESTINATION"
else
  SIM_UDID="$(ensure_sim)" || exit 1
  TEST_DEST="platform=iOS Simulator,id=$SIM_UDID"
fi

echo "Testing scheme '$SCHEME_NAME' (destination: $TEST_DEST) → log: $LOG"
set +e
set -o pipefail
xcodebuild "$FLAG" "$CONTAINER" \
  -scheme "$SCHEME_NAME" \
  -destination "$TEST_DEST" \
  -derivedDataPath "$DERIVED_DATA" \
  -quiet \
  test "$@" 2>&1 | tee "$LOG" | filter_xcode_log
STATUS=${PIPESTATUS[0]}
set -e

echo "--- Summary ---"
grep -E "Test Suite .*(passed|failed)" "$LOG" | tail -5 || true
FAILS=$(grep -cE "Test Case .* failed" "$LOG" 2>/dev/null || true)
if [ "$STATUS" -eq 0 ]; then
  echo "TESTS PASSED"
else
  echo "TESTS FAILED (exit $STATUS, ${FAILS:-?} case failed). Full log: $LOG"
  echo "--- Failed cases ---"
  grep -E "Test Case .* failed|error:|XCTAssert" "$LOG" | sort -u | head -40 || true
fi
exit "$STATUS"
