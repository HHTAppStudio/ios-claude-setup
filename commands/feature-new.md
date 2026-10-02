---
description: Scaffold feature mới theo chuẩn MVVM + feature-first của dự án
argument-hint: <TênFeature> [mô tả ngắn]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Tạo feature mới: $ARGUMENTS

1. Đọc `.claude/rules/feature-scaffold.md` và `.claude/rules/folder-structure.md` của dự án (nếu có) để lấy cấu trúc chuẩn. Fallback khi chưa cài rules: `Features/<Tên>/{Views,ViewModels,Models}`.
2. Khảo sát 1 feature có sẵn gần giống nhất (giao agent `explorer` nếu cần quét nhiều) để bắt chước convention thực tế: naming, cách inject dependency, cách đăng ký navigation.
3. Tạo file:
   - `<Tên>View.swift` — view tối thiểu bind vào ViewModel.
   - `<Tên>ViewModel.swift` — state + action rỗng theo pattern dự án đang dùng (`@Observable` hay `ObservableObject` — nhìn code có sẵn, đừng đoán; dự án mới mặc định `@Observable`).
   - Đăng ký route/navigation nếu dự án có router.
4. Tạo test stub cho ViewModel theo framework test dự án đang dùng (XCTest hay Swift Testing — nhìn test có sẵn).
5. Chạy `/build`; pass thì báo lại danh sách file đã tạo + việc còn lại người dùng cần quyết (nội dung màn hình, service).

KHÔNG tự bịa business logic — scaffold là khung rỗng đúng chuẩn, nội dung do người dùng quyết.
