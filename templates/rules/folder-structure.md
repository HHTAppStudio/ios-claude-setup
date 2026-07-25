---
paths:
  - "**/*.swift"
---

# Folder Structure & Placement

<!-- Template — điền theo dự án thực tế. -->

```
<AppName>/
├── App/               # entry point, AppDelegate, DI setup
├── Features/
│   └── <Feature>/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/    # model chỉ feature này dùng
├── Core/
│   ├── Services/      # dùng chung ≥2 feature
│   ├── Models/        # model dùng chung
│   ├── Extensions/
│   └── UI/            # component tái sử dụng
└── Resources/
```

## Placement Rules

- Code mới mặc định nằm trong feature. Chỉ chuyển vào `Core/` khi ≥2 feature thực sự dùng.
- Một file một type chính; tên file = tên type.
- Test đặt tại <!-- e.g. <AppName>Tests/<Feature>/ --> mirror theo cấu trúc source.
