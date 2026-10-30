---
paths:
  - "**/Features/**"
  - "**/Design/**"
  - "**/*App.swift"
  - "**/*.plist"
  - "**/*.pbxproj"
---

# Adaptive Layout — iPhone, iPhone Duo, iPad

Một binary chạy ở nhiều kích thước, và kích thước đổi GIỮA phiên (gập/mở Duo, cửa sổ iPad, Split View). Layout đọc không gian view đang có, không đoán máy.

| Màn | Cỡ (pt) | Size class ngang/dọc | Xoay |
|---|---|---|---|
| iPhone thường | ~375–440 × 812–956 | compact/regular | dọc |
| Duo đóng | 466 × 678 | compact/regular | như iPhone |
| Duo mở | 669 × 951 | regular/regular, cả hai chiều | không khoá được |
| iPad | cửa sổ co giãn tới cả màn | bất kỳ | mọi chiều |

Bảng để hình dung, KHÔNG đưa số nào vào code. Duo không có idiom riêng và không có API "đang ở màn nào".

## Cấu hình dự án

- Build bằng Xcode 27.1+ (iOS 27.1 SDK): SDK cũ hơn thì app không dùng hết màn trong của Duo. SDK này KHÔNG đòi nâng deployment target; API mới bọc `#available`.
- Có launch screen (`UILaunchScreen` hoặc `INFOPLIST_KEY_UILaunchScreen_Generation`): thiếu là App Store từ chối (ITMS-90870).
- Dự án mới không đặt `UIRequiresFullScreen`: iOS 27 bỏ qua nó, app vẫn bị resize. Dự án cũ đang có: chỉ gỡ khi layout đã chịu được cửa sổ iPad — gỡ xong là app co giãn ngay.
- Khai báo orientation rộng, thu hẹp bằng code:

```
INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
```

## Orientation

Mặc định: màn có cạnh ngắn từ 600pt xoay tự do (iPad, Duo mở); iPhone thường và Duo đóng giữ dọc. Muốn iPhone xoay ngang là quyết định product — Claude không tự mở.

```swift
// Trong UIApplicationDelegate (@UIApplicationDelegateAdaptor).
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    guard let screen = window?.windowScene?.screen else { return .portrait }
    return min(screen.bounds.width, screen.bounds.height) >= 600 ? .all : .portrait
}
```

- Đây là chỗ DUY NHẤT được đo màn. Đo screen chứ không đo window: cửa sổ bị khoá dọc thì tự nó cũng hẹp.
- Không khoá orientation theo từng màn (`requestGeometryUpdate`, override mask trong một view): màn trong của Duo không tuân theo.
- Layout không đọc orientation. Cần "rộng hơn cao" thì so `size.width > size.height` của khung đang có.

## Quyết định layout — dừng ở bậc đầu tiên đủ dùng

1. Container hệ thống: `NavigationStack`, `NavigationSplitView`, `TabView`, `List`, `ScrollView`, sheet, alert tự thích nghi với thanh dọc và nếp gập. Đừng tự chế cái chúng làm được.
2. Co giãn không rẽ nhánh: `ViewThatFits`, `GridItem(.adaptive(minimum:))`, `.frame(maxWidth:)`.
3. Size class ở cấp màn: viết `== .regular`, không viết `!= .compact` (nil cũng lọt). Chiều rộng đọc `horizontalSizeClass`, chiều cao đọc `verticalSizeClass`.
4. Số đo khung thật (`GeometryReader`, `onGeometryChange`) khi cần con số; `proxy.size` đã trừ safe area sẵn. Ngưỡng là một hằng số có đặt tên, không phải danh sách máy.

Cấm dùng cho layout: `UIScreen.main`, `UIDevice.current.orientation`, `interfaceOrientation`, `userInterfaceIdiom`, helper kiểu `isPad`, so sánh `bounds.height == 844`.

Bẫy:
- `regular` KHÔNG có nghĩa là iPad: Duo mở cũng regular, và iPad trong cửa sổ hẹp lại là compact.
- Sheet báo `compact` dù nằm trên iPad vì bản thân nó hẹp. Trong sheet, chia cột theo bề rộng thật.
- Rẽ `if` theo size class tạo view identity khác: `@State` bên trong nhánh mất khi gập/mở. Giữ state ở trên nhánh.

## Màn rộng và màn thấp

- Nội dung đọc/chạm thu vào cột: `.frame(maxWidth:)` với hằng số trong `Theme` (danh sách ~600pt, thanh tìm kiếm ~430pt). Thu CẢ cột (title, nút, list) để thẳng hàng. Nền và map vẫn tràn màn.
- Cột căn giữa là mức sàn, không phải đích: màn danh sách → chi tiết nên cân nhắc `NavigationSplitView` ở regular.
- Duo mở ngang chỉ cao ~669pt, iPad mini ngang ~744pt. Màn dài lùi dần bằng `ViewThatFits`: cỡ lớn → cỡ nhỏ → `ScrollView`. Nút chính không được rơi khỏi đáy.
- Ảnh/video `aspectFill` có thể mất nội dung trên màn gần vuông: kiểm tra phần quan trọng còn nằm trong khung, chữ đặt ngoài vùng bị cắt.

## Safe area

- Inset trái/phải và trên/dưới KHÔNG đối xứng; thanh trạng thái Duo là inset NGANG tồn tại cả phiên, có ở cả màn dọc. Không suy ra inset từ size hay orientation, không lưu lại, không so với ngưỡng.
- `.ignoresSafeArea()` trần chỉ cho lớp nền (màu, map, phim). Nội dung đọc/chạm giữ trong safe area; thanh tự chế dùng `safeAreaBar` (iOS 26+) hoặc `safeAreaInset`, không dùng `ZStack` + padding cứng.
- Cần biết thanh hệ thống nằm cạnh nào: `@Environment(\.toolbarVerticalEdge)` (iOS 27.1), không suy từ size class.
- `TabView(.page)` tràn qua inset ngang thì trang lệch và trang sau lấn vào. Trang full-bleed dùng `ScrollView` + `.scrollTargetBehavior(.paging)` + `.containerRelativeFrame` (iOS 17+).
- Nút cửa sổ iPad đè góc trên trái khi app chạy trong cửa sổ co giãn. Control nhỏ dùng `containerCornerOffset(.leading)`; hàng trải hết bề ngang thì đẩy xuống theo `containerCornerInsets` đo ở GỐC màn (iOS 26+). Trang trong `TabView` không thấy góc cửa sổ: đo ngoài rồi truyền vào.

## Nếp gập

- Không làm layout riêng cho từng tư thế. Container, sheet, alert, menu tự né nếp gập.
- Control đặt tay gần giữa màn: né bằng `proxy.reservedRegions(kind: .division)` (iOS 27.1, `#available`); nếp gập chỉ active khi gập dở.
- Lưới nên ra số cột chẵn để không có ô nằm trên nếp gập.
- `onHingeChange` chỉ cho hiệu ứng, không cho layout. `ArrangementView` (iOS 27.1) không đặt trong `List`/`ScrollView`, không bọc `NavigationSplitView`.

## Giữ state khi đổi kích thước

Gập/mở là thay đổi trait và size, không phải scene disconnect. Không fetch lại, không reset form hay vị trí cuộn, không dùng `.id(size)`. Việc đắt tiền theo size chỉ chạy khi size thật sự đổi.

Multi-window: chỉ bật khi product cần. Đã bật thì state màn hình không được nằm trong singleton, và `@AppStorage` dùng chung mọi cửa sổ.

## Verify

Chạm layout thì `/run` trên từng loại máy rồi đọc screenshot:

```
/run                                # SIM_DEVICE: iPhone thường
/run --device "iPhone Duo"          # simulator mới tạo hiện màn NGOÀI
/run --device "iPad mini (A17 Pro)" # tên lấy từ: xcrun simctl list devicetypes
```

- Soát: cả hai chiều ở Duo mở và iPad; cửa sổ iPad hẹp (~375pt); Dynamic Type lớn; sheet và màn dài.
- Đọc cỡ screenshot để biết đang ở màn nào: 1398×2034 là màn ngoài, 2007×2853 là màn trong. Screenshot đen hoặc chỉ có màn chờ thì đặt `RUN_WAIT_SECONDS` lớn hơn trong `.claude/ios.env` rồi `/run` lại (simulator vừa boot lần đầu cần ~20s).
- Tư thế Duo KHÔNG đổi được bằng CLI: mở máy và gập dở là người dùng làm trong Device Hub của Xcode. Tư thế nào chưa có screenshot thì Claude nêu rõ là chưa validate, không suy ra từ màn còn lại.
- Trong UI test, trang dựng sẵn nằm ngoài màn thì hỏi `isHittable` là lỗi: lọc theo frame trước.
- App Store: nộp thêm screenshot Duo 2007×2853 (màn trong) và 1398×2034 (màn ngoài) để có badge "optimized for iPhone Duo".
- Audit app cũ: `xcrun agent skills export --output-dir <dir>`, dùng skill `app-resizability` của Apple.

Nguồn: [Prepare for iPhone Duo](https://developer.apple.com/iphone-duo/prepare/), [Tech Talk Adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/), [TN3192](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key).
