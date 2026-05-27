# Quản Lý Thu Chi

Ứng dụng Flutter/Dart quản lý thu chi cá nhân, lưu dữ liệu cục bộ bằng SQLite và hiển thị thống kê theo tháng.

## Tính năng

- Thêm, sửa, xóa giao dịch thu/chi.
- Lọc giao dịch theo tháng.
- Tìm kiếm giao dịch theo tiêu đề.
- Tự động chọn icon theo nội dung giao dịch.
- Biểu đồ chi tiêu bằng `fl_chart`.
- Hỗ trợ giao diện sáng/tối.

## Công nghệ

- Flutter
- Dart
- Provider
- Local storage với `shared_preferences`
- `intl` cho định dạng ngày và tiền tệ tiếng Việt

## Chạy project

```powershell
flutter pub get
flutter run
```

Nếu project được clone từ GitHub mà thiếu thư mục nền tảng Android, chạy:

```powershell
flutter create --platforms=android .
flutter pub get
flutter run
```

## Ghi chú setup

Project lưu dữ liệu cục bộ trên thiết bị/trình duyệt. Khi chạy web, dữ liệu nằm trong local storage của browser đang dùng.
