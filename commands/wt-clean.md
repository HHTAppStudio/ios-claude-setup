---
description: Xoá worktree + branch đã merge xong
argument-hint: <tên-task>
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh:*)
---

Dọn dẹp worktree: $ARGUMENTS

1. Chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh clean $1`.
2. Nếu script báo branch chưa merge: KHÔNG tự động dùng `-f`. Báo người dùng rõ là thay đổi sẽ mất vĩnh viễn và chỉ chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh clean $1 -f` khi người dùng xác nhận.
