---
description: Cài rules + config của ios-toolkit vào dự án hiện tại (chạy 1 lần cho mỗi repo)
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

Cài đặt ios-toolkit vào dự án hiện tại. Plugin không tự load được rules nên bước này copy chúng vào repo.

1. Kiểm tra đây là git repo có `.xcodeproj`/`.xcworkspace`. Nếu không, báo và dừng.

2. Ghi nhận TRƯỚC khi copy: `.claude/ios.env` đã có chưa — có nghĩa là dự án cũ đã init (dùng ở bước 6). Rồi copy template (KHÔNG ghi đè file đã tồn tại):
```bash
mkdir -p .claude/rules
for f in "${CLAUDE_PLUGIN_ROOT}/templates/rules/"*.md; do
  [ -f ".claude/rules/$(basename "$f")" ] || cp "$f" .claude/rules/
done
[ -f .claude/ios.env ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/ios.env" .claude/ios.env
[ -f CLAUDE.md ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md" CLAUDE.md
```

3. Bổ sung `.gitignore` (chỉ thêm dòng còn thiếu): `.claude/logs/`, `.claude/settings.local.json`, `.claude/ios.env`, `.derived-data/`

4. Tự động điền config thay vì để trống:
   - Chạy `xcodebuild -list` để lấy scheme, điền `SCHEME` vào `.claude/ios.env`.
   - Chạy `xcrun simctl list devicetypes | grep iPhone | tail -5`, chọn device type iPhone thường mới nhất có trên máy (không chọn iPhone Duo — Duo chạy bằng `/run --device`), điền vào `SIM_DEVICE` (KHÔNG đặt `DESTINATION` — để trống cho cơ chế simulator-riêng-mỗi-worktree hoạt động).
   - Điền `MAIN_BRANCH` từ branch hiện tại hoặc origin/HEAD.
   - Điền phần **Project** trong `CLAUDE.md` (iOS target, devices, architecture) bằng cách đọc nhanh project settings — hỏi người dùng phần không tự suy ra được (iOS target không hỏi: theo bước 5).

5. Kiểm tra platform nhất quán giữa các target (app, Tests, UITests):
```bash
grep -n "IPHONEOS_DEPLOYMENT_TARGET\|TARGETED_DEVICE_FAMILY\|SUPPORTED_PLATFORMS" *.xcodeproj/project.pbxproj
```
   `IPHONEOS_DEPLOYMENT_TARGET` mặc định là 17.0 ở MỌI target (kể cả Tests/UITests — Xcode hay để chúng ở bản mới nhất): khác 17.0 thì tự sửa về 17.0, không hỏi, rồi báo lại đã đổi từ số nào. Ngoại lệ duy nhất: `CLAUDE.md` có sẵn của dự án đã chốt số khác thì giữ số đó.

   Còn lại, mặc định khuyến nghị `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone + iPad), `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`. Xcode hay để device family của Tests/UITests kèm `7` (Vision) — báo người dùng và đề nghị sửa cho khớp app target (sửa xong phải `/build` lại). KHÔNG tự sửa khi chưa được đồng ý.

   Kiểm tra thêm cấu hình màn hình (đọc cả `*.pbxproj`, `.xcconfig` và Info.plist của app target), đối chiếu với mục "Cấu hình dự án" trong `.claude/rules/adaptive-layout.md`: có launch screen, có `UIRequiresFullScreen` không, orientation iPhone và iPad. Chỉ báo người dùng, KHÔNG tự sửa — gỡ `UIRequiresFullScreen` là app co giãn ngay, mở orientation là app xoay được, layout có thể chưa sẵn sàng.

6. SwiftFormat + SwiftLint (hook chỉ chạy chúng khi dự án có config). Dự án cũ đã init (xem bước 2): bỏ qua cả bước, không hỏi, không tạo config — config mới sẽ làm hook format lại và bắt lỗi trên code cũ.

   Dự án mới: kiểm tra `command -v swiftformat` và `command -v swiftlint`.
   - Có đủ cả hai → tạo config luôn, không hỏi.
   - Thiếu → hỏi người dùng có muốn cài cái còn thiếu không (`brew install <tên>`). Đồng ý thì cài; cài thành công thì tạo config. Từ chối hoặc cài lỗi thì KHÔNG tạo config, và báo rõ hook format/lint sẽ không chạy ở dự án này.

   Tạo config (không ghi đè, và commit cùng dự án để worktree cũng có):
```bash
[ -f .swiftformat ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/swiftformat" .swiftformat
[ -f .swiftlint.yml ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/swiftlint.yml" .swiftlint.yml
```

7. Nhắc người dùng: các placeholder trong `.claude/rules/*.md` (architecture, integrations…) cần điền theo dự án — đề nghị giúp điền luôn bằng cách khảo sát codebase (giao agent `explorer`). KHÔNG cài SDK chung nào trong `integrations.md` ở bước init — chúng chỉ được thêm khi một feature cần tới.

8. Verify: chạy `"${CLAUDE_PLUGIN_ROOT}/scripts/build.sh"` — pass là cài đặt xong.
