---
description: Merge an toàn một worktree về nhánh chính (rebase → build verify → merge --no-ff)
argument-hint: <tên-task>
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh:*), Bash(git:*), Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/build.sh:*), Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/test.sh:*)
---

Merge worktree về nhánh chính: $ARGUMENTS

1. Trước khi merge, dùng agent `code-reviewer` review diff của branch `claude/$1` so với nhánh chính. Nếu có blocking finding, báo người dùng và DỪNG.
2. Chạy: `"${CLAUDE_PLUGIN_ROOT}"/scripts/wt.sh merge $1`
   - Script tự làm: kiểm tra working tree sạch → rebase lên nhánh chính → build verify → merge --no-ff.
3. Nếu rebase conflict: script sẽ abort và báo. Hỏi người dùng có muốn resolve conflict tại worktree không; nếu có, resolve tại worktree đó (đọc cả hai phía, giữ intent của cả hai thay đổi), rồi chạy lại merge.
4. Nếu build fail sau rebase: sửa trong worktree (giao cho agent `builder`), rồi chạy lại merge.
5. Sau khi merge thành công: gợi ý `/wt-clean $1`.

Khi merge nhiều worktree liên tiếp: merge TỪNG worktree một, worktree sau sẽ tự rebase lên kết quả của worktree trước — không merge đồng thời.
