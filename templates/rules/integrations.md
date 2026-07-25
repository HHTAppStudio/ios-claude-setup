---
paths:
  - "**/Services/**"
  - "**/*.plist"
  - "**/Package.swift"
  - "**/Podfile"
---

# Integrations

<!-- Template — liệt kê SDK/service bên ngoài. Chỉnh `paths` ở trên theo nơi đặt code tích hợp của dự án. -->

| SDK / Service | Dùng để | Lưu ý |
|---|---|---|
| <!-- Firebase --> | <!-- analytics, crash --> | <!-- config file không commit --> |
| <!-- backend API --> | <!-- base URL, auth --> | <!-- env nào, token ở đâu --> |

## Rules

- Không thêm dependency mới khi chưa được đồng ý.
- Key/secret không hardcode, không commit.
