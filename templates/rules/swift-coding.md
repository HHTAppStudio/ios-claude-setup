---
paths:
  - "**/*.swift"
---

# Swift / SwiftUI / Combine Guidelines

<!-- Template — chỉnh theo convention của team. -->

## Swift

- Swift API Design Guidelines; tên rõ nghĩa hơn tên ngắn.
- `let` mặc định; `var` chỉ khi thực sự mutate.
- Không force unwrap (`!`) ngoài test; dùng `guard let` với early return.
- Error: throw domain error cụ thể, không nuốt lỗi im lặng.

## SwiftUI

- View nhỏ, tách subview khi body > ~50 dòng.
- Observation (target 17.0): `@Observable` + `@State` (view sở hữu) / `@Bindable` (cần binding) / truyền thẳng (chỉ đọc). Dự án cũ đang dùng `ObservableObject` → theo rule bên dưới, không tự migrate.
- Không tạo ViewModel trong body hay đưa side effect vào body.
- Theo pattern observation ĐANG CÓ trong codebase — không trộn hai kiểu trong cùng dự án.

## Persistence (SwiftData)

- Database local mặc định là SwiftData. Có sẵn Core Data/khác trong dự án → theo cái đang có, không trộn.
- `ModelContainer` tạo một lần ở `App/`, inject vào Service/Repository qua init.
- `ModelContext` chỉ dùng trong Service/Repository; ViewModel gọi repository, View không đụng context.
- Đổi schema `@Model` đã ship → thêm `VersionedSchema` + migration plan, không sửa thẳng.

## Combine / Concurrency

- <!-- e.g. Combine cho stream UI, async/await cho request một lần -->
- Hủy subscription theo lifecycle (store trong `Set<AnyCancellable>` của owner).
- UI update trên MainActor.
