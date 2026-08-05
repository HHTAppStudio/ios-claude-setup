---
description: Cài rules + config của ios-toolkit vào dự án hiện tại (chạy 1 lần cho mỗi repo)
allowed-tools: Bash, Read, Edit, Write
---

Cài đặt ios-toolkit vào dự án hiện tại. Plugin không tự load được rules nên bước này copy chúng vào repo.

1. Kiểm tra đây là git repo có `.xcodeproj`/`.xcworkspace`. Nếu không, báo và dừng.

2. Copy template (KHÔNG ghi đè file đã tồn tại):
```bash
mkdir -p .claude/rules
cp -n "${CLAUDE_PLUGIN_ROOT}/templates/rules/"*.md .claude/rules/
[ -f .claude/ios.env ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/ios.env" .claude/ios.env
[ -f CLAUDE.md ] || cp "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md" CLAUDE.md
```

3. Bổ sung `.gitignore` (chỉ thêm dòng còn thiếu): `.claude/logs/`, `.claude/settings.local.json`, `.claude/ios.env`, `.derived-data/`

4. Tự động điền config thay vì để trống:
   - Chạy `xcodebuild -list` để lấy scheme, điền `SCHEME` vào `.claude/ios.env`.
   - Chạy `xcrun simctl list devicetypes | grep iPhone | tail -5`, chọn device type iPhone mới nhất có trên máy, điền vào `SIM_DEVICE` (KHÔNG đặt `DESTINATION` — để trống cho cơ chế simulator-riêng-mỗi-worktree hoạt động).
   - Điền `MAIN_BRANCH` từ branch hiện tại hoặc origin/HEAD.
   - Điền phần **Project** trong `CLAUDE.md` (iOS target, devices, architecture) bằng cách đọc nhanh project settings — hỏi người dùng phần không tự suy ra được.

5. Kiểm tra platform nhất quán giữa các target (app, Tests, UITests):
```bash
grep -n "IPHONEOS_DEPLOYMENT_TARGET\|TARGETED_DEVICE_FAMILY\|SUPPORTED_PLATFORMS" *.xcodeproj/project.pbxproj
```
   Mặc định khuyến nghị: `IPHONEOS_DEPLOYMENT_TARGET` giống nhau ở mọi target, `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone + iPad), `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`. Xcode hay để target Tests/UITests ở deployment target mới nhất và device family kèm `7` (Vision) — báo người dùng và đề nghị sửa cho khớp app target (sửa xong phải `/build` lại). KHÔNG tự sửa khi chưa được đồng ý.

6. Nhắc người dùng: các placeholder trong `.claude/rules/*.md` (architecture, integrations…) cần điền theo dự án — đề nghị giúp điền luôn bằng cách khảo sát codebase (giao agent `explorer`).

7. Verify: chạy `"${CLAUDE_PLUGIN_ROOT}/scripts/build.sh"` — pass là cài đặt xong.
