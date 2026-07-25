#!/usr/bin/env bash
# Shared helpers — source từ build.sh / test.sh / wt.sh
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# Config per-project: .claude/ios.env (cài bằng /ios-init); fallback vị trí cũ scripts/project.env
for env_file in "$ROOT/.claude/ios.env" "$ROOT/scripts/project.env"; do
  if [ -f "$env_file" ]; then source "$env_file"; break; fi
done

LOG_DIR="$ROOT/.claude/logs"
mkdir -p "$LOG_DIR"

# Mỗi worktree dùng DerivedData riêng để build song song không đụng nhau.
DERIVED_DATA="$ROOT/.derived-data"

# Device type dùng để tạo simulator riêng cho test (đổi trong .claude/ios.env nếu cần).
SIM_DEVICE="${SIM_DEVICE:-iPhone 16}"

# Tên simulator riêng cho một worktree — hash theo path để không trùng giữa các dự án/worktree.
sim_name_for() {
  echo "claude-$(basename "$1")-$(printf '%s' "$1" | /usr/bin/shasum | cut -c1-6)"
}

# Trả về UDID simulator riêng của worktree hiện tại; tự tạo nếu chưa có.
# Nhờ đó nhiều worktree test song song không tranh nhau một máy ảo.
ensure_sim() {
  local sim_name udid devtype_id
  sim_name="$(sim_name_for "$ROOT")"
  udid=$(xcrun simctl list devices available | grep -F "$sim_name (" | head -1 \
    | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')
  if [ -z "$udid" ]; then
    devtype_id=$(xcrun simctl list devicetypes | grep -F "$SIM_DEVICE (" | head -1 \
      | sed -E 's/.*\((com\.apple[^)]+)\).*/\1/')
    if [ -z "$devtype_id" ]; then
      echo "ERROR: không tìm thấy device type '$SIM_DEVICE' (xem: xcrun simctl list devicetypes)" >&2
      return 1
    fi
    udid=$(xcrun simctl create "$sim_name" "$devtype_id")
    echo "Đã tạo simulator riêng cho worktree: $sim_name" >&2
  fi
  echo "$udid"
}

detect_container() {
  # Ưu tiên workspace, fallback project. In ra dạng "-workspace X" hoặc "-project Y".
  if [ -n "${WORKSPACE:-}" ]; then echo "-workspace|$WORKSPACE"; return; fi
  if [ -n "${PROJECT:-}" ]; then echo "-project|$PROJECT"; return; fi
  local ws pj
  ws=$(ls -d "$ROOT"/*.xcworkspace 2>/dev/null | head -1 || true)
  pj=$(ls -d "$ROOT"/*.xcodeproj 2>/dev/null | head -1 || true)
  if [ -n "$ws" ]; then echo "-workspace|$ws"
  elif [ -n "$pj" ]; then echo "-project|$pj"
  else echo "ERROR: không tìm thấy .xcworkspace/.xcodeproj trong $ROOT" >&2; exit 1
  fi
}

detect_scheme() {
  if [ -n "${SCHEME:-}" ]; then echo "$SCHEME"; return; fi
  IFS='|' read -r flag container <<< "$(detect_container)"
  xcodebuild "$flag" "$container" -list 2>/dev/null \
    | sed -n '/Schemes:/,/^$/p' | sed '1d' | sed 's/^ *//' | grep -v '^$' | head -1
}

main_branch() {
  if [ -n "${MAIN_BRANCH:-}" ]; then echo "$MAIN_BRANCH"; return; fi
  git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' \
    || { git show-ref --verify --quiet refs/heads/main && echo main; } \
    || echo master
}

# Lọc log xcodebuild: chỉ giữ error/warning/kết quả test — phần Claude cần đọc.
filter_xcode_log() {
  if command -v xcbeautify >/dev/null 2>&1; then
    xcbeautify --quieter
  else
    grep -E "(error:|warning:|BUILD (SUCCEEDED|FAILED)|TEST (SUCCEEDED|FAILED)|Test Case .*(failed|passed)|✗|failing)" || true
  fi
}
