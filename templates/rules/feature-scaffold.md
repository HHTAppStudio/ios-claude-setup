---
paths:
  - "**/Features/**"
---

# Feature Scaffold

Scaffold chuẩn khi thêm feature mới — bắt đầu TỐI THIỂU, mở rộng khi phức tạp:

```
Features/<FeatureName>/
├── Views/<FeatureName>View.swift
├── ViewModels/<FeatureName>ViewModel.swift
└── Models/            # nếu cần
```

Khi feature phức tạp lên (≥2 màn hình, nghiệp vụ riêng, subview tái sử dụng), mở rộng theo cấu trúc trong `folder-structure.md`: thêm `Services/` cho nghiệp vụ riêng của feature, `Views/Components/` cho subview nội bộ, tách `<SubFeature>/` cho nhánh có flow riêng. Mỗi màn hình mới = một cặp View + ViewModel.

## Checklist

1. Tạo ViewModel trước, định nghĩa state + action.
2. View chỉ bind vào ViewModel.
3. Service mới → đặt trong `Features/<FeatureName>/Services/`; chỉ đưa vào `Core/` khi feature thứ hai cần.
4. Đăng ký route/navigation theo rule architecture (nếu có màn hình mới).
5. Viết test cho ViewModel logic chính.
6. `/build` pass trước khi báo done.
7. Khi THÊM màn hình vào feature có sẵn: theo cấu trúc feature đó đang dùng; nếu đang phẳng mà đã ≥2 màn hình, đề xuất nâng cấp cấu trúc (không tự refactor khi chưa được đồng ý).
