---
description: Build project (output đã lọc, tiết kiệm token)
allowed-tools: Bash("${CLAUDE_PLUGIN_ROOT}"/scripts/build.sh:*)
---

Chạy `"${CLAUDE_PLUGIN_ROOT}"/scripts/build.sh`.

- Nếu pass: báo ngắn gọn.
- Nếu fail với lỗi cơ học (syntax, thiếu import, sai signature): giao cho agent `builder` sửa đến khi pass.
- Nếu fail do vấn đề thiết kế: tóm tắt lỗi và hỏi hướng xử lý.
