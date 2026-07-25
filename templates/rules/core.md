# Core Rules

<!-- Không có `paths` → luôn được load, như CLAUDE.md. Chỉ giữ rule áp dụng cho MỌI task. -->

1. Ưu tiên thay đổi rõ ràng, cục bộ, ít rủi ro.
2. Giữ nguyên behavior trừ khi task yêu cầu thay đổi.
3. Không đặt business logic trong View.
4. Mỗi mutable state có đúng một owner.
5. Code giữ trong feature trừ khi việc tái sử dụng đã được chứng minh.
6. Không tạo abstraction khi chưa có lợi ích rõ.
7. UI thay đổi phải cân nhắc mọi device được hỗ trợ.
8. Nêu rõ giả định, rủi ro, và phần chưa validate.
