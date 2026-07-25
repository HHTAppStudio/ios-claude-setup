#!/usr/bin/env bash
# wt.sh — quản lý git worktree cho các phiên Claude chạy song song.
#
#   ./scripts/wt.sh new <name>       Tạo worktree + branch claude/<name>
#   ./scripts/wt.sh list             Liệt kê worktree + trạng thái so với nhánh chính
#   ./scripts/wt.sh merge <name>     Merge an toàn về nhánh chính (rebase → verify → merge --no-ff)
#   ./scripts/wt.sh clean <name>     Xoá worktree + branch (chỉ khi đã merge)
#   ./scripts/wt.sh clean <name> -f  Xoá kể cả khi chưa merge (mất thay đổi!)
#
# Worktree đặt tại: ../<repo>-worktrees/<name>
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

REPO_NAME="$(basename "$ROOT")"
WT_BASE="${WORKTREE_BASE:-$(dirname "$ROOT")/${REPO_NAME}-worktrees}"
MAIN="$(main_branch)"

usage() { sed -n '2,10p' "$0"; exit 1; }

require_clean() {
  if ! git -C "$1" diff --quiet || ! git -C "$1" diff --cached --quiet; then
    echo "ERROR: '$1' có thay đổi chưa commit. Commit hoặc stash trước." >&2
    exit 1
  fi
}

cmd="${1:-}"; name="${2:-}"

case "$cmd" in
  new)
    [ -n "$name" ] || usage
    branch="claude/$name"
    path="$WT_BASE/$name"
    [ -e "$path" ] && { echo "ERROR: $path đã tồn tại." >&2; exit 1; }
    mkdir -p "$WT_BASE"
    git -C "$ROOT" worktree add -b "$branch" "$path" "$MAIN"
    # Mang theo config local không được commit (nếu có)
    for f in .claude/settings.local.json .claude/ios.env; do
      if [ -f "$ROOT/$f" ] && [ ! -f "$path/$f" ]; then
        mkdir -p "$path/$(dirname "$f")"
        cp "$ROOT/$f" "$path/$f"
      fi
    done
    # CocoaPods: Pods/ thường không được commit → worktree mới phải install lại
    if [ -f "$path/Podfile" ]; then
      if command -v pod >/dev/null 2>&1; then
        echo "==> Podfile phát hiện — chạy pod install cho worktree mới"
        (cd "$path" && pod install) || echo "WARNING: pod install fail — chạy tay: cd $path && pod install" >&2
      else
        echo "WARNING: dự án dùng CocoaPods nhưng máy chưa có lệnh 'pod' — build sẽ fail nếu thiếu Pods/." >&2
      fi
    fi
    echo ""
    echo "✓ Worktree sẵn sàng: $path (branch $branch, từ $MAIN)"
    echo "  Chạy phiên Claude song song:  cd $path && claude"
    ;;

  list)
    echo "Nhánh chính: $MAIN"
    git -C "$ROOT" worktree list
    echo ""
    for b in $(git -C "$ROOT" for-each-ref --format='%(refname:short)' refs/heads/claude/); do
      ahead=$(git -C "$ROOT" rev-list --count "$MAIN..$b")
      behind=$(git -C "$ROOT" rev-list --count "$b..$MAIN")
      merged=$(git -C "$ROOT" merge-base --is-ancestor "$b" "$MAIN" && echo "đã merge" || echo "chưa merge")
      echo "  $b: +$ahead/-$behind so với $MAIN ($merged)"
    done
    ;;

  merge)
    [ -n "$name" ] || usage
    branch="claude/$name"
    path="$WT_BASE/$name"
    [ -d "$path" ] || { echo "ERROR: không thấy worktree $path" >&2; exit 1; }

    echo "==> 1/4 Kiểm tra sạch sẽ (cả worktree lẫn repo chính)"
    require_clean "$path"
    require_clean "$ROOT"

    echo "==> 2/4 Rebase $branch lên $MAIN"
    if ! git -C "$path" rebase "$MAIN"; then
      git -C "$path" rebase --abort || true
      echo "ERROR: rebase có conflict. Mở phiên Claude tại $path để resolve:"
      echo "  cd $path && git rebase $MAIN   # resolve rồi chạy lại merge"
      exit 1
    fi

    echo "==> 3/4 Verify build sau rebase"
    (cd "$path" && "$SCRIPT_DIR/build.sh") || { echo "ERROR: build fail sau rebase — sửa trong worktree rồi merge lại." >&2; exit 1; }
    if [ "${MERGE_REQUIRE_TESTS:-0}" = "1" ]; then
      (cd "$path" && "$SCRIPT_DIR/test.sh") || { echo "ERROR: test fail sau rebase." >&2; exit 1; }
    fi

    echo "==> 4/4 Merge --no-ff vào $MAIN"
    git -C "$ROOT" checkout "$MAIN"
    git -C "$ROOT" merge --no-ff "$branch" -m "Merge $branch: $name"
    echo ""
    echo "✓ Đã merge $branch vào $MAIN. Dọn dẹp: ./scripts/wt.sh clean $name"
    ;;

  clean)
    [ -n "$name" ] || usage
    branch="claude/$name"
    path="$WT_BASE/$name"
    force="${3:-}"
    if [ -n "$force" ] && [ "$force" != "-f" ]; then
      echo "ERROR: tham số không hợp lệ '$force' (chỉ chấp nhận '-f')." >&2
      usage
    fi
    if [ "$force" != "-f" ]; then
      if ! git -C "$ROOT" merge-base --is-ancestor "$branch" "$MAIN" 2>/dev/null; then
        echo "ERROR: $branch chưa merge vào $MAIN. Dùng '-f' nếu chắc chắn muốn bỏ." >&2
        exit 1
      fi
    fi
    # Xoá simulator riêng của worktree này (nếu từng được tạo cho test)
    xcrun simctl delete "$(sim_name_for "$path")" >/dev/null 2>&1 || true
    if [ -d "$path" ]; then
      git -C "$ROOT" worktree remove ${force:+--force} "$path" || {
        echo "ERROR: worktree còn thay đổi chưa commit hoặc file untracked. Kiểm tra lại, hoặc dùng '-f' để bỏ hẳn." >&2
        exit 1
      }
    fi
    del_flag="-d"; [ -n "$force" ] && del_flag="-D"
    git -C "$ROOT" branch "$del_flag" "$branch" 2>/dev/null || true
    git -C "$ROOT" worktree prune
    echo "✓ Đã xoá worktree + branch $branch"
    ;;

  *) usage ;;
esac
