# Core Rules

<!-- Không có `paths` → luôn được load, như CLAUDE.md. Chỉ giữ rule áp dụng cho MỌI task. -->

1. Ưu tiên thay đổi rõ ràng, cục bộ, ít rủi ro.
2. Giữ nguyên behavior trừ khi task yêu cầu thay đổi.
3. Không đặt business logic trong View.
4. Mỗi mutable state có đúng một owner.
5. Code giữ trong feature trừ khi việc tái sử dụng đã được chứng minh.
6. Không tạo abstraction khi chưa có lợi ích rõ.
7. UI thay đổi phải cân nhắc mọi device được hỗ trợ (mặc định iPhone + iPad).
8. Platform mặc định là iOS + iPadOS, deployment target 16.0 — cho MỌI target kể cả Tests/UITests. KHÔNG tự nâng target hay thêm platform (macOS/visionOS/Catalyst) để làm cho code compile; API mới hơn thì tìm cách thay thế, hoặc dừng và hỏi.
9. Nêu rõ giả định, rủi ro, và phần chưa validate.
10. KHÔNG tự ý chạy full UI test suite. UI test chỉ chạy khi user đồng ý, và chỉ chạy `-only-testing:` khoanh đúng phần liên quan tới điểm sửa — muốn chạy phải hỏi trước.
