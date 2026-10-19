# Nodo PM — Giao diện mới "Dark Premium" gate theo tài khoản

> Ngày: 2026-07-24 · Trạng thái: chờ duyệt spec

## 1. Mục tiêu

Phát triển một giao diện mới (dark premium, phong cách Apple / Xiaomi) **song song** với UI hiện tại,
**chỉ bật cho một số tài khoản test** (bắt đầu là `anhpt@nodo.vn`) trên app đang chạy thật —
**không ảnh hưởng người dùng production**. Nội dung/nghiệp vụ giữ nguyên, chỉ đổi bố cục & cách thể hiện.

## 2. Cơ chế gate (hardcoded email list)

- Thêm `AppFlags` (hoặc mở rộng `Utils`): `Set<String> betaUiEmails = {'anhpt@nodo.vn'}` + `isBetaUiUser(String? email)`.
- Nguồn email: `GlobalData.instance.userProfile?.email` (đã dùng cho bypass location).
- Đổi danh sách = sửa code + build lại (chấp nhận, theo lựa chọn của chủ dự án).

## 3. Kiến trúc — song song, an toàn cho app live

**Vấn đề:** các màn hiện tại gọi thẳng `AppColors.<const>` (không qua `Theme.of(context)`),
nên không thể chỉ swap `ThemeData` để đổi toàn bộ.

**Giải pháp:** xây **lớp UI v2 tách biệt**, KHÔNG sửa màn cũ:
- `lib/app/core/theme_v2/` — design tokens + components dùng chung.
- `lib/app/features/ui_v2/` — các màn v2.
- Tại root điều hướng (`bottom_navigation.dart` hoặc `app.dart`): nếu `isBetaUiUser` → dựng **shell v2**; ngược lại giữ UI cũ **nguyên vẹn**.

→ User thật không bị ảnh hưởng vì code cũ không đụng tới.

## 4. Design system v2 (dark premium)

Tokens (`theme_v2/app_tokens.dart`), theo style "Modern Dark (Cinema Mobile)":
- Nền: `bgDeep #020203`, `bgTop #0d0d14` (tránh #000 thuần — đỡ lem OLED), `elevated rgba(255,255,255,.05)`
- Chữ: `fg #EDEDEF`, `muted #8A8F98`
- Accent: `#0A84FF` (xanh iOS) + `#5E6AD2` (tím), `glow rgba(10,132,255,.35)`
- Viền hairline `rgba(255,255,255,.09)`, radius `20`, easing `cubic-bezier(.16,1,.3,1)`
- Font: San Francisco (iOS) / system; fallback Plus Jakarta Sans

Components v2 tái sử dụng:
- `GlassCard` (BackdropFilter blur + hairline border)
- `PrimaryButton` (spring press 0.97 + HapticFeedback)
- `AmbientBackground` (2–3 blob ánh sáng trôi chậm)
- `SectionHeader`, `UtilityTile`, `TaskRow`, `GlassBottomNav`

## 5. Điều hướng (đúng thực tế — sửa theo góp ý)

5 tab, map đúng màn hiện có:
`Trang chủ (HomePage)` · `Nhân viên (StaffPage)` · `Chấm công (CheckInPage, giữa)` · `Nghỉ phép (OnLeavePage)` · `Cá nhân (AccountPage)`.

## 6. Home v2 — Phase 1 (nội dung giữ nguyên)

Tái dùng `HomeCubit` / dữ liệu hiện có, chỉ thay trình bày:
- **Header:** avatar + "Xin chào, {name}" + "Cố gắng hết mình hôm nay nhé!" + chuông (badge).
- **Hero chấm công:** "Hôm nay · {ngày}", **Chấm Công Vào / Chấm Công Ra** (giờ + trạng thái), nút "Chấm công ra".
- **Tiện ích (6):** Nhân viên · Dữ liệu công · Nghỉ phép · Chấm công · Việc cần làm · Đơn từ (giữ nguyên điều hướng cũ).
- **Việc cần làm:** danh sách từ dữ liệu cũ + "Xem tất cả".

## 7. Animation

- `flutter_animate`: stagger entrance (translateY 22→0 + fade, expo-out), sweep shimmer trên hero.
- `BackdropFilter`: glass cards + bottom nav.
- Implicit animations + `HapticFeedback.lightImpact` khi bấm.
- Ambient blobs: `AnimatedBuilder`/`AnimatedPositioned` loop chậm (16–22s).
- Tôn trọng `MediaQuery.disableAnimations` (reduce motion).

## 8. Phạm vi & phân kỳ

- **Phase 1 (spec này):** infra gate + `theme_v2` tokens + core components + **Home v2** + shell điều hướng v2 (các tab khác tạm trỏ về màn cũ, cuốn chiếu sau).
- Phase 2: Chấm công v2.
- Phase 3: Nhân viên / Nghỉ phép / Cá nhân v2.
- Mỗi phase: spec nhỏ → plan → implement.

## 9. Non-goals (Phase 1)

- Không redesign toàn bộ màn cùng lúc.
- Không đổi backend/API/nghiệp vụ.
- Chưa làm light mode cho v2 (chỉ dark ở giai đoạn đầu).

## 10. An toàn / rollout

- Không sửa màn cũ → production không đổi.
- Chỉ TestFlight; mở rộng danh sách email dần.
- Không commit lên nhánh chung khi chưa chốt (theo yêu cầu).
