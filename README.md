# ios-toolkit — Claude Code plugin cho dự án iOS

Plugin Claude Code dùng chung cho các dự án iOS (Swift/SwiftUI), cài trực tiếp từ GitHub. Ba mục tiêu:

1. **Tiết kiệm token** — agents gán model rẻ (haiku/sonnet) + build/test wrapper chỉ đưa lỗi vào context thay vì dump log xcodebuild.
2. **Tuân thủ rules dự án** — path-scoped rules (tự load khi đụng file khớp glob) cài vào repo qua `/ios-init`, hook SwiftLint tự chạy sau mỗi lần sửa file Swift.
3. **Làm việc song song** — worktree riêng cho từng task, mỗi worktree một phiên Claude, merge an toàn (rebase → build verify → merge --no-ff).

## Cài đặt

```
/plugin marketplace add HHTAppStudio/ios-claude-setup
/plugin install ios-toolkit@ios-claude-setup
```

Sau đó trong mỗi dự án iOS, chạy một lần:

```
/ios-init
```

`/ios-init` copy rules + config template vào repo (không ghi đè file có sẵn), tự detect scheme/simulator/branch chính để điền `.claude/ios.env`, và giúp điền phần Project trong `CLAUDE.md`. Plugin không tự load được rules vào project — đây là lý do cần bước này.

Khuyến nghị thêm: `brew install xcbeautify swiftlint` (không bắt buộc — scripts tự fallback). Nếu dự án có file config `.swiftformat`, cài thêm `swiftformat` để hook tự format file vừa sửa.

### Hooks tự động

- **Chặn secrets** (PreToolUse): Claude không tự sửa được `.env`, `*.p8/p12/pem/mobileprovision`, `Secrets.swift`, `GoogleService-Info.plist` — tránh lộ/hỏng credential.
- **Format + lint** (PostToolUse): file `.swift` vừa sửa được SwiftFormat (chỉ khi repo có `.swiftformat`) rồi SwiftLint; warning được đưa lại cho Claude tự sửa.

### Kết hợp với XcodeBuildMCP (tuỳ chọn)

Plugin này thuần shell script — không cần Node/MCP, hoạt động cả trong CI. Nếu bạn cần thêm UI automation (tap/swipe), LLDB debugging, hay deploy lên device thật, cài thêm [XcodeBuildMCP](https://www.xcodebuildmcp.com/) song song — hai bên không xung đột: dùng `/build`, `/test`, `/run` cho vòng lặp hằng ngày (rẻ token, có cách ly worktree), dùng XcodeBuildMCP cho thao tác tương tác sâu.

## Lệnh

| Lệnh | Chức năng |
|---|---|
| `/ios-init` | Cài rules + config vào dự án (chạy 1 lần/repo) |
| `/build` | Build, chỉ in lỗi (full log ra `.claude/logs/`) |
| `/test [Target/Class]` | Chạy test khoanh vùng hoặc full suite |
| `/run` | Build + chạy app trên simulator, chụp screenshot để Claude kiểm tra UI |
| `/clean` | Xoá DerivedData của worktree + dọn log cũ (khi nghi lỗi cache) |
| `/feature-new <Tên>` | Scaffold feature mới theo chuẩn MVVM + convention có sẵn của dự án |
| `/wt-new <tên>` | Tạo worktree + branch `claude/<tên>` để làm song song |
| `/wt-list` | Trạng thái các worktree (ahead/behind, đã merge chưa) |
| `/wt-merge <tên>` | Review → rebase → build verify → merge --no-ff |
| `/wt-clean <tên>` | Xoá worktree + branch đã merge |

Hỗ trợ các loại dự án: `.xcworkspace` / `.xcodeproj`, Swift package thuần (`swift build`/`swift test`), dự án generate project bằng **XcodeGen/Tuist** (worktree mới tự generate), CocoaPods (worktree mới tự `pod install`). Output test nhận diện cả **XCTest** lẫn **Swift Testing** (Xcode 16+).

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
hooks/hooks.json             # PreToolUse → chặn sửa file secrets; PostToolUse → SwiftFormat + SwiftLint file .swift vừa sửa
scripts/                     # build.sh, test.sh, run.sh, clean.sh, wt.sh, _common.sh, lint-changed.sh, protect-secrets.sh
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

An toàn merge do `scripts/wt.sh` đảm bảo: từ chối khi working tree bẩn; rebase trước, conflict thì abort chứ không merge bừa; build verify sau rebase (bật thêm test: `MERGE_REQUIRE_TESTS=1` trong `.claude/ios.env`); merge `--no-ff` để revert được nguyên task.

## Vì sao build song song không đụng nhau

Các xung đột kinh điển khi chạy nhiều worktree iOS cùng lúc đều đã được xử lý trong scripts:

| Xung đột | Cách xử lý |
|---|---|
| DerivedData chung | Mỗi worktree có `.derived-data/` riêng |
| Hai phiên test tranh một simulator | `test.sh` tự tạo **simulator riêng cho mỗi worktree** (đặt tên theo hash path, tạo từ `SIM_DEVICE`); `/wt-clean` tự xoá máy ảo đó |
| Build tranh simulator | `build.sh` dùng destination `generic/platform=iOS Simulator` — chỉ compile, không đụng máy ảo nào |
| Worktree mới thiếu `Pods/` | `wt.sh new` tự chạy `pod install` nếu có Podfile |
| SPM package cache chung | SPM tự lock (`~/Library/Caches/org.swift.swiftpm`), an toàn; package checkout nằm trong DerivedData riêng của từng worktree |
| Log lẫn nhau | Log ghi vào `.claude/logs/` của từng worktree |

Đã kiểm chứng bằng cách build song song 2 worktree trên một dự án iOS thật.

## Phát hành / cập nhật plugin

- Repo public: `HHTAppStudio/ios-claude-setup`.
- Tăng `version` trong `.claude-plugin/plugin.json` khi có thay đổi.
- Người dùng cập nhật: `/plugin marketplace update ios-claude-setup` rồi cài lại plugin.
- Test local trước khi push: `/plugin marketplace add /đường/dẫn/tới/repo-này`.
