---
paths:
  - "**/Features/**"
---

# Feature Scaffold

Scaffold chuẩn khi thêm feature mới:

```
Features/<FeatureName>/
├── Views/<FeatureName>View.swift
├── ViewModels/<FeatureName>ViewModel.swift
└── Models/            # nếu cần
```

## Checklist

1. Tạo ViewModel trước, định nghĩa state + action.
2. View chỉ bind vào ViewModel.
3. Service mới → đặt trong feature; chỉ đưa vào `Core/` khi feature thứ hai cần.
4. Đăng ký route/navigation theo rule architecture (nếu có màn hình mới).
5. Viết test cho ViewModel logic chính.
6. `/build` pass trước khi báo done.
