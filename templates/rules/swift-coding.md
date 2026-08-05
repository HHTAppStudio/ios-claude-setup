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
- Observation: <!-- chọn MỘT theo min deployment target của dự án:
  - iOS 17+: `@Observable` ViewModel; view giữ bằng `@State`, truyền xuống bằng `@Bindable`.
  - iOS 16 trở xuống: `ObservableObject` + `@StateObject` (view sở hữu) / `@ObservedObject` (được inject). -->
- Không tạo ViewModel trong body hay đưa side effect vào body.
- Theo pattern observation ĐANG CÓ trong codebase — không trộn hai kiểu trong cùng dự án.

## Combine / Concurrency

- <!-- e.g. Combine cho stream UI, async/await cho request một lần -->
- Hủy subscription theo lifecycle (store trong `Set<AnyCancellable>` của owner).
- UI update trên MainActor.
