---
paths:
  - "**/Services/**"
  - "**/*.plist"
  - "**/Package.swift"
  - "**/Podfile"
  - "**/*.pbxproj"
---

# Integrations

<!-- Chỉnh `paths` ở trên theo nơi đặt code tích hợp của dự án. Bổ sung SDK/service riêng của dự án vào bảng thứ hai. -->

## SDK chung (ưu tiên dùng khi feature cần tới)

Không phải repo nào cũng cài sẵn. Khi một feature cần tới chức năng bên dưới, SDK tương ứng luôn là lựa chọn ưu tiên: repo chưa có thì thêm vào lúc đó, đã có thì dùng luôn.

| SDK | Dùng cho | Repo (SPM) | Products | Pin |
|---|---|---|---|---|
| AdsKit | hiển thị ad, consent (UMP) + ATT | `git@github.com:HoiAeTayNgangCoder/AdsKit.git` | `AdsKit`, `AdsKitGoogle` | exactVersion |
| AnalyticsKit | analytics, crashlytics, remote config | `git@github.com:HoiAeTayNgangCoder/AnalyticsKit.git` | `AnalyticsKit`, `AnalyticsKitFirebase` | exactVersion |
| NetworkSDK | gọi API, xử lý mạng | `git@github.com:HoiAeTayNgangCoder/NetworkSDK.git` | `NetworkSDK` | exactVersion |
| PurchaseKit | subscription / in-app purchase | `git@github.com:HoiAeTayNgangCoder/PurchaseKit.git` | `PurchaseKit` | exactVersion |
| Kingfisher | tải + cache ảnh online | `https://github.com/onevcat/Kingfisher.git` | `Kingfisher` | upToNextMajorVersion |

- Chỉ thêm đúng SDK mà feature đang làm cần — không add cả bộ "cho sẵn". 5 SDK này đã được duyệt sẵn, không cần hỏi trước khi thêm.
- KHÔNG tự viết lại hoặc thêm lib khác cho các việc trên: không wrapper `URLSession`/Alamofire riêng, không gọi StoreKit/Firebase/Google Mobile Ads trực tiếp, không `AsyncImage` cho ảnh online. SDK thiếu tính năng → dừng và báo, không tự vá ở app.
- Version: khi task cần tới SDK (vd. user yêu cầu gắn quảng cáo → AdsKit), fetch tag mới nhất của repo ngay lúc đó rồi pin theo tag ấy — `git ls-remote --tags --refs <repo> | awk -F/ '{print $NF}' | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1` (bỏ tag beta/rc). Tag có tiền tố `v` → ghi version không có `v` (tag `v1.4.1` → `version = 1.4.1`). Không dùng version nhớ sẵn hay copy từ dự án khác. Dự án đã có SDK thì giữ version đang pin; nâng version phải được đồng ý.
- `AnalyticsKitFirebase` cần `GoogleService-Info.plist` — hook `protect-secrets` chặn Claude tạo/sửa file này → nhờ user tự thêm.
- 4 kit private cần SSH key có quyền vào org `HoiAeTayNgangCoder`; resolve fail vì auth → báo user, không đổi sang HTTPS hay fork.
- Mẫu tích hợp tham khảo: dự án `ios-carplay` (cùng thư mục cha với repo này trên máy dev) — xem cách khai báo package, link product, setup ở `App/`.

## SDK / service riêng của dự án

| SDK / Service | Dùng để | Lưu ý |
|---|---|---|
| <!-- backend API --> | <!-- base URL, auth --> | <!-- env nào, token ở đâu --> |

## Rules

- Ngoài các SDK chung ở trên: không thêm dependency mới khi chưa được đồng ý.
- Key/secret không hardcode, không commit.
