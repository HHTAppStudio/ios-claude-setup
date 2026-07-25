#!/usr/bin/env bash
# Test wrapper — chỉ in kết quả tóm tắt và test fail (tiết kiệm token).
# Usage: ./scripts/test.sh [-only-testing:Target/Class/testMethod] [extra args...]
source "$(dirname "$0")/_common.sh"

IFS='|' read -r FLAG CONTAINER <<< "$(detect_container)"
SCHEME_NAME="$(detect_scheme)"
LOG="$LOG_DIR/test-$(date +%Y%m%d-%H%M%S).log"

echo "Testing scheme '$SCHEME_NAME' → log: $LOG"
set +e
set -o pipefail
xcodebuild "$FLAG" "$CONTAINER" \
  -scheme "$SCHEME_NAME" \
  -destination "$DESTINATION" \
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
  grep -E "Test Case .* failed|error:|XCTAssert" "$LOG" | sort -u | head -40
fi
exit "$STATUS"
