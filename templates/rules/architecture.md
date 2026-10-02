---
paths:
  - "**/*.swift"
---

# Architecture

<!-- Template — điền theo dự án thực tế. Tự load khi Claude đụng vào file Swift. -->

## Layers

- **View** (SwiftUI): chỉ render + forward action. Không business logic, không gọi service trực tiếp.
- **ViewModel** (`@Observable`): state + logic của một màn hình. Owner duy nhất của state màn hình đó.
- **Service / Repository**: nghiệp vụ và data access (database local = SwiftData), không biết gì về UI.
- **Model**: struct thuần, không dependency. Ngoại lệ: `@Model` class của SwiftData cho dữ liệu lưu local.

## Ownership & Dependency

- Chiều dependency: View → ViewModel → Service → Model. Không đi ngược.
- Service dùng chung inject qua <!-- Environment / init / DI container -->.
- Singleton chỉ dành cho: <!-- liệt kê, e.g. AudioManager, SessionManager -->

## Navigation

- <!-- e.g. AppRouter + AppRoute enum; push/pop qua router, không NavigationLink lồng sâu -->
