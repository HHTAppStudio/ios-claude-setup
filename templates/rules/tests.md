---
paths:
  - "**/*Tests/**"
  - "**/*Tests.swift"
  - "**/*UITests/**"
---

# Test Rules

- Test behavior, không test implementation detail.
- Tên test: `test_<hành vi>_<điều kiện>_<kết quả>`.
- ViewModel test không cần UI; mock service qua protocol.
- Chạy test bằng lệnh `/test` của plugin ios-toolkit (hỗ trợ `-only-testing:` để khoanh vùng) — không gọi xcodebuild trực tiếp.
