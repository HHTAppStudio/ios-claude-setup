---
description: Build + chạy app trên simulator, chụp screenshot để kiểm tra UI thật
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/run.sh:*), Read
---

Chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/run.sh`.

Script tự làm: build cho simulator riêng của worktree → install → launch → chụp screenshot → thu runtime log.

Sau khi script chạy xong:
1. ĐỌC file screenshot (.png) mà script in ra — kiểm tra UI có render đúng không (layout vỡ, màn hình trắng, thiếu data…).
2. Nếu script cảnh báo crash: đọc runtime log, xác định nguyên nhân; lỗi cơ học thì giao agent `builder` sửa, lỗi thiết kế thì tóm tắt và hỏi người dùng.
3. Báo lại: app chạy được không, UI trông thế nào (mô tả từ screenshot), điểm bất thường nếu có.

Dùng lệnh này để verify thay đổi UI — `/build` chỉ chứng minh compile được, không chứng minh app chạy đúng.
