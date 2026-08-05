#!/usr/bin/env bash
# PreToolUse hook: chặn Edit/Write vào file chứa secret/credential.
# Exit 2 + stderr → Claude bị chặn và thấy lý do; người dùng sửa tay nếu thật sự cần.
set -uo pipefail

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || echo "")
[ -n "$file" ] || exit 0

case "$(basename "$file")" in
  .env|.env.*|*.pem|*.p8|*.p12|*.mobileprovision|*.keychain|*.certSigningRequest|Secrets.swift|secrets.json|GoogleService-Info.plist)
    echo "BLOCKED: '$file' có thể chứa secret/credential — plugin ios-toolkit chặn tự sửa file này. Nếu thật sự cần, hãy nhờ người dùng sửa tay hoặc xác nhận rồi sửa ngoài hook." >&2
    exit 2
    ;;
esac
exit 0
