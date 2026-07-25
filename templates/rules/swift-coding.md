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
- State: `@State` cho UI cục bộ, `@StateObject` cho ViewModel do view sở hữu, `@ObservedObject` khi được inject.
- Không tạo `@StateObject` trong body hay đưa side effect vào body.

## Combine / Concurrency

- <!-- e.g. Combine cho stream UI, async/await cho request một lần -->
- Hủy subscription theo lifecycle (store trong `Set<AnyCancellable>` của owner).
- UI update trên MainActor.
