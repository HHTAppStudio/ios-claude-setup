#!/usr/bin/env bash
# Xoá DerivedData riêng của worktree hiện tại + log/screenshot cũ hơn 7 ngày.
# Dùng khi build ra lỗi khó hiểu nghi do cache (stale module cache, build product cũ).
source "$(dirname "$0")/_common.sh"

if [ -d "$DERIVED_DATA" ]; then
  rm -rf "$DERIVED_DATA"
  echo "✓ Đã xoá $DERIVED_DATA"
else
  echo "Không có $DERIVED_DATA — chưa build lần nào hoặc đã sạch."
fi
find "$LOG_DIR" \( -name "*.log" -o -name "*.png" \) -mtime +7 -delete 2>/dev/null || true
echo "✓ Đã dọn log/screenshot cũ hơn 7 ngày trong $LOG_DIR"
