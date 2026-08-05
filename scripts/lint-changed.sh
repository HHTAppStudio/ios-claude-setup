#!/usr/bin/env bash
# PostToolUse hook: chạy SwiftLint trên file .swift vừa được Edit/Write.
# Im lặng bỏ qua nếu không phải file Swift hoặc SwiftLint chưa cài.
set -uo pipefail

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")
[[ "$file" == *.swift && -f "$file" ]] || exit 0

# Auto-format bằng SwiftFormat — CHỈ khi dự án có config .swiftformat
# (tôn trọng style team đã chọn, không tự áp đặt default).
if command -v swiftformat >/dev/null 2>&1; then
  repo_root="$(cd "$(dirname "$file")" && git rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -n "$repo_root" ] && [ -f "$repo_root/.swiftformat" ]; then
    swiftformat --quiet "$file" >/dev/null 2>&1 || true
  fi
fi

command -v swiftlint >/dev/null 2>&1 || exit 0

out=$(swiftlint lint --quiet "$file" 2>/dev/null | head -20)
if [ -n "$out" ]; then
  # exit 2 + stderr → Claude nhìn thấy cảnh báo và tự sửa
  echo "SwiftLint issues in $file:" >&2
  echo "$out" >&2
  exit 2
fi
exit 0
