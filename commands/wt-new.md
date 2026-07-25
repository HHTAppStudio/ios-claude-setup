---
description: Tạo worktree + branch claude/<name> để làm task song song
argument-hint: <tên-task-kebab-case> [mô tả task]
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh:*), Bash(git worktree list:*)
---

Tạo worktree mới cho task: $ARGUMENTS

1. Lấy tên task (từ đầu tiên của arguments, kebab-case). Nếu người dùng chưa cho tên, đặt tên ngắn gọn từ mô tả task.
2. Chạy: `"${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh new <tên>`
3. Báo lại cho người dùng:
   - Đường dẫn worktree và tên branch.
   - Lệnh mở phiên Claude song song: `cd <path> && claude`
   - Nếu arguments có mô tả task, gợi ý prompt khởi đầu cho phiên mới đó.

KHÔNG tự cd vào worktree hay bắt đầu code trong phiên hiện tại — worktree dành cho phiên song song, trừ khi người dùng yêu cầu làm tại đây.
