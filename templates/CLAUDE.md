# CLAUDE.md

## Project

<!-- Điền thông tin dự án khi cài vào repo. Giữ ngắn — mỗi dòng một fact. -->
- iOS app
- Swift, SwiftUI, Combine
- **Platform mặc định: iOS + iPadOS, deployment target 17.0** — áp dụng cho MỌI target (app, Tests, UITests): `IPHONEOS_DEPLOYMENT_TARGET = 17.0`, `TARGETED_DEVICE_FAMILY = "1,2"`, `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`, `SDKROOT = iphoneos`. Đổi được, nhưng phải là quyết định product — Claude không tự đổi.
- Devices: iPhone, iPad
- Database local mặc định: **SwiftData** (không dùng Core Data / Realm / SQLite wrapper trừ khi dự án đã có sẵn).
- Architecture: MVVM + feature-first
- Scheme chính: xem `.claude/ios.env`

## Rules

Rules của dự án nằm trong `.claude/rules/` và được Claude Code tự load:

- `core.md` — rule chung, luôn được load.
- Các rule còn lại có `paths` frontmatter, chỉ tự load khi đụng vào file khớp glob (Swift code → architecture, folder-structure, swift-coding; test → tests; Features/ → feature-scaffold; Services//plist → integrations).
- KHÔNG cần chủ động đọc `.claude/rules/` — cơ chế auto-load lo việc đó. Khi thêm rule mới, path-scope nó nếu có thể.

## Token Policy (bắt buộc)

- KHÔNG chạy `xcodebuild` trực tiếp. Luôn dùng lệnh `/build`, `/test`, `/run` của plugin ios-toolkit — chúng ghi full log ra file và chỉ in lỗi.
- Thay đổi UI: verify bằng `/run` (chạy app trên simulator + đọc screenshot), không chỉ `/build`.
- KHÔNG đọc toàn bộ file lớn; đọc đúng range cần thiết.
- Việc tìm kiếm / khảo sát nhiều file: giao cho agent `explorer` (haiku).
- Việc sửa lỗi compile lặp lại, chạy test: giao cho agent `builder` / `test-runner` (sonnet).
- Chỉ dùng main thread (model mạnh nhất) cho: quyết định kiến trúc, review khó, plan.

## Agents & Model Routing

| Agent | Model | Dùng khi |
|---|---|---|
| `explorer` | haiku | tìm code, khảo sát cấu trúc, trả lời "ở đâu/cái gì" |
| `builder` | sonnet | build + sửa lỗi compile lặp lại |
| `test-runner` | sonnet | chạy test, tổng hợp failure |
| `doc-writer` | haiku | viết/ cập nhật docs, comment, changelog |
| `planner` | inherit | chia task lớn thành phase |
| `code-reviewer` | inherit | review thay đổi non-trivial trước khi merge |

## Worktree Workflow (làm việc song song)

- Tạo nhánh làm việc riêng: `/wt-new <tên-task>` — tạo git worktree + branch `claude/<tên-task>`.
- Mỗi worktree là một thư mục độc lập → mở phiên Claude riêng trong đó để chạy song song.
- Merge về nhánh chính: `/wt-merge <tên-task>` — tự rebase, build verify, rồi merge --no-ff.
- Dọn dẹp: `/wt-clean <tên-task>`. Xem trạng thái: `/wt-list`.
- KHÔNG commit trực tiếp lên nhánh chính khi đang có worktree mở cho cùng vùng code.

## Done

- Task hoàn thành đúng yêu cầu.
- `/build` pass (và `/test` nếu chạm logic, `/run` + xem screenshot nếu chạm UI).
- Placement đúng layer/folder theo architecture.
- Đã review hoặc nêu rõ gap chưa validate.
