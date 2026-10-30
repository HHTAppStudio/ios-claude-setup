#!/usr/bin/env bash
# PostToolUse hook: chạy SwiftFormat + SwiftLint trên file .swift vừa được Edit/Write.
# Mỗi công cụ CHỈ chạy khi dự án có config của nó (.swiftformat, .swiftlint.yml) —
# dự án cũ chưa có config không bị ảnh hưởng. Im lặng bỏ qua nếu không phải file
# Swift hoặc công cụ chưa cài.
set -uo pipefail

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")
[[ "$file" == *.swift && -f "$file" ]] || exit 0

repo_root="$(cd "$(dirname "$file")" && git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$repo_root" ] || exit 0

if command -v swiftformat >/dev/null 2>&1 && [ -f "$repo_root/.swiftformat" ]; then
  swiftformat --quiet "$file" >/dev/null 2>&1 || true
fi

command -v swiftlint >/dev/null 2>&1 && [ -f "$repo_root/.swiftlint.yml" ] || exit 0

out=$(swiftlint lint --quiet --config "$repo_root/.swiftlint.yml" "$file" 2>/dev/null | head -20)
if [ -n "$out" ]; then
  # exit 2 + stderr → Claude nhìn thấy cảnh báo và tự sửa
  echo "SwiftLint issues in $file:" >&2
  echo "$out" >&2
  exit 2
fi
exit 0
