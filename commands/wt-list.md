---
description: Liệt kê các worktree/branch claude/* và trạng thái merge
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh:*)
---

Chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh list` và tóm tắt cho người dùng:

- Worktree nào đang mở, branch nào ahead/behind so với nhánh chính.
- Branch nào đã merge → gợi ý `/wt-clean <tên>`.
- Branch nào behind nhiều → cảnh báo nên merge sớm để tránh conflict lớn.
