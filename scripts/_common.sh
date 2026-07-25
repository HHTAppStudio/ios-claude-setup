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
