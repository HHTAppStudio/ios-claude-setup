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
│       ├── Models/    # model chỉ feature này dùng
│       └── Services/  # nghiệp vụ riêng của feature (khi phức tạp — xem bên dưới)
├── Core/
│   ├── Services/      # dùng chung ≥2 feature
│   ├── Models/        # model dùng chung
│   ├── Extensions/
│   └── UI/            # component tái sử dụng
└── Resources/
```

## Cấu trúc bên trong một feature

Feature **đơn giản** (1 màn hình, không nghiệp vụ riêng) — giữ phẳng, không tạo folder thừa:

```
Features/<Feature>/
├── Views/<Feature>View.swift
├── ViewModels/<Feature>ViewModel.swift
└── Models/            # chỉ tạo khi có model riêng
```

Feature **phức tạp** (≥2 màn hình, hoặc có nghiệp vụ riêng) — mở rộng dần theo nhu cầu:

```
Features/<Feature>/
├── Views/
│   ├── <Feature>View.swift        # màn hình chính / entry của feature
│   ├── <MànHình>View.swift        # mỗi màn hình một file
│   └── Components/                # subview tái sử dụng TRONG feature này
├── ViewModels/
│   ├── <Feature>ViewModel.swift
│   └── <MànHình>ViewModel.swift   # mỗi màn hình một ViewModel — không nhồi chung
├── Models/                        # model chỉ feature này dùng
├── Services/                      # nghiệp vụ riêng của feature (API, cache, logic…)
└── <SubFeature>/                  # nhánh con đủ lớn → tách sub-feature, lặp lại cấu trúc trên
```

Quy tắc mở rộng:

- Mỗi màn hình một cặp View + ViewModel. ViewModel chung cho nhiều màn hình chỉ khi các màn hình đó thao tác trên cùng một state (vd wizard nhiều bước).
- `Services/` của feature: tạo khi feature có nghiệp vụ riêng — KHÔNG đặt vội vào `Core/Services/`. Chuyển lên Core khi feature thứ hai thực sự cần.
- `Views/Components/`: subview dùng lại trong feature. Chuyển lên `Core/UI/` khi ≥2 feature dùng.
- Tách `<SubFeature>/` khi một nhánh có flow riêng với ≥2 màn hình (vd `Checkout/` trong `Cart/`). Sub-feature không import ngang sang sub-feature khác — giao tiếp qua ViewModel/Service của feature cha.
- Chỉ tạo folder khi có ≥1 file thật đặt vào — không scaffold sẵn folder rỗng.

## Placement Rules

- Code mới mặc định nằm trong feature. Chỉ chuyển vào `Core/` khi ≥2 feature thực sự dùng.
- Một file một type chính; tên file = tên type.
- Test đặt tại <!-- e.g. <AppName>Tests/<Feature>/ --> mirror theo cấu trúc source (kể cả sub-feature).
