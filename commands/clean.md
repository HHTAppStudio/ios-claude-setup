---
description: Xoá DerivedData của worktree hiện tại + dọn log cũ
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/clean.sh:*)
---

Chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/clean.sh` và báo kết quả ngắn gọn.

Dùng khi build ra lỗi khó hiểu nghi do cache (stale module, build product cũ sau khi đổi branch/rebase). Sau khi clean, build lại bằng `/build` để xác nhận.
