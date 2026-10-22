import 'package:flutter/material.dart';

/// Bọc màn v2 có nút ở đáy đặt trong `Scaffold.bottomSheet` (Lưu / Gửi duyệt / ...): bỏ nền
/// mặc định của khung bottomSheet (Material 3: nền sáng surfaceContainerLow, bo góc 28) để
/// chỉ còn đúng cái nút.
///
/// Trước đây khung nền sáng này nằm sau nút: nút xanh che gần hết nên chỉ lộ viền trắng,
/// còn nút mờ (chưa nhập đủ) bán trong suốt nên trông như cả dải trắng tràn màn hình là nút
/// → hai trạng thái lệch kích thước.
///
/// Popup mở từ trong màn (showModalBottomSheet không truyền màu) giữ nguyên màu/độ nổi cũ.
class BottomSheetBarThemeV2 extends StatelessWidget {
  final Widget child;

  const BottomSheetBarThemeV2({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheet = theme.bottomSheetTheme;
    final m3 = theme.useMaterial3;
    return Theme(
      data: theme.copyWith(
        bottomSheetTheme: sheet.copyWith(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Giá trị popup đang dùng trước khi đổi (mặc định của Material).
          modalBackgroundColor: sheet.modalBackgroundColor ??
              sheet.backgroundColor ??
              (m3 ? theme.colorScheme.surfaceContainerLow : theme.canvasColor),
          modalElevation: sheet.modalElevation ?? sheet.elevation ?? (m3 ? 1.0 : 0.0),
        ),
      ),
      child: child,
    );
  }
}
