# ios-toolkit — Claude Code plugin cho dự án iOS

Plugin Claude Code dùng chung cho các dự án iOS (Swift/SwiftUI), cài trực tiếp từ GitHub. Ba mục tiêu:

1. **Tiết kiệm token** — agents gán model rẻ (haiku/sonnet) + build/test wrapper chỉ đưa lỗi vào context thay vì dump log xcodebuild.
2. **Tuân thủ rules dự án** — path-scoped rules (tự load khi đụng file khớp glob) cài vào repo qua `/ios-init`, hook SwiftLint tự chạy sau mỗi lần sửa file Swift.
3. **Làm việc song song** — worktree riêng cho từng task, mỗi worktree một phiên Claude, merge an toàn (rebase → build verify → merge --no-ff).

## Cài đặt

```
/plugin marketplace add hoanghust/ios-claude-setup
/plugin install ios-toolkit@ios-claude-setup
```

Sau đó trong mỗi dự án iOS, chạy một lần:

```
/ios-init
```

`/ios-init` copy rules + config template vào repo (không ghi đè file có sẵn), tự detect scheme/simulator/branch chính để điền `.claude/ios.env`, và giúp điền phần Project trong `CLAUDE.md`. Plugin không tự load được rules vào project — đây là lý do cần bước này.

Khuyến nghị thêm: `brew install xcbeautify swiftlint` (không bắt buộc — scripts tự fallback).

## Lệnh

| Lệnh | Chức năng |
|---|---|
| `/ios-init` | Cài rules + config vào dự án (chạy 1 lần/repo) |
| `/build` | Build, chỉ in lỗi (full log ra `.claude/logs/`) |
| `/test [Target/Class]` | Chạy test khoanh vùng hoặc full suite |
| `/wt-new <tên>` | Tạo worktree + branch `claude/<tên>` để làm song song |
| `/wt-list` | Trạng thái các worktree (ahead/behind, đã merge chưa) |
| `/wt-merge <tên>` | Review → rebase → build verify → merge --no-ff |
| `/wt-clean <tên>` | Xoá worktree + branch đã merge |

## Agents (model routing)

| Agent | Model | Dùng khi |
|---|---|---|
| `explorer` | haiku | tìm code, khảo sát cấu trúc |
| `doc-writer` | haiku | viết/cập nhật docs |
| `builder` | sonnet | vòng lặp build-fix cơ học |
| `test-runner` | sonnet | chạy test, tổng hợp fail |
| `planner` | inherit | chia task lớn thành phase |
| `code-reviewer` | inherit | review trước merge |

## Cấu trúc repo

```
.claude-plugin/
├── plugin.json              # manifest plugin
└── marketplace.json         # repo này đồng thời là marketplace (source: "./")
commands/                    # slash commands (ios-init, build, test, wt-*)
agents/                      # 6 subagent có gán model
hooks/hooks.json             # PostToolUse → SwiftLint file .swift vừa sửa
scripts/                     # build.sh, test.sh, wt.sh, _common.sh, lint-changed.sh
templates/                   # /ios-init copy vào dự án
├── CLAUDE.md                # project facts + token policy + workflow
├── ios.env                  # SCHEME, DESTINATION, MAIN_BRANCH…
└── rules/                   # path-scoped rules (.claude/rules/ của dự án)
    ├── core.md              #   luôn load
    ├── architecture.md      #   load khi đụng *.swift
    ├── folder-structure.md  #   load khi đụng *.swift
    ├── swift-coding.md      #   load khi đụng *.swift
    ├── tests.md             #   load khi đụng *Tests*
    ├── feature-scaffold.md  #   load khi đụng Features/
    └── integrations.md      #   load khi đụng Services/, *.plist, Podfile…
```

## Workflow song song

```bash
/wt-new fix-player-crash          # phiên chính tạo worktree
/wt-new add-settings-screen

# mỗi terminal một phiên Claude:
cd ../<repo>-worktrees/fix-player-crash && claude

# xong task nào merge task đó, tuần tự:
/wt-merge fix-player-crash        # review → rebase → build verify → merge --no-ff
/wt-clean fix-player-crash
/wt-merge add-settings-screen     # tự rebase lên kết quả merge trước
```

An toàn merge do `scripts/wt.sh` đảm bảo: từ chối khi working tree bẩn; rebase trước, conflict thì abort chứ không merge bừa; build verify sau rebase (bật thêm test: `MERGE_REQUIRE_TESTS=1` trong `.claude/ios.env`); merge `--no-ff` để revert được nguyên task. Mỗi worktree có DerivedData riêng (`.derived-data/`) nên build song song không phá cache của nhau.

## Phát hành / cập nhật plugin

- Push repo này lên GitHub (`hoanghust/ios-claude-setup`).
- Tăng `version` trong `.claude-plugin/plugin.json` khi có thay đổi.
- Người dùng cập nhật: `/plugin marketplace update ios-claude-setup` rồi cài lại plugin.
- Test local trước khi push: `/plugin marketplace add /đường/dẫn/tới/repo-này`.
