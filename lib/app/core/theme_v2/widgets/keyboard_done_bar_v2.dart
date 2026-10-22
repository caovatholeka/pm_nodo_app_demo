import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_tokens_v2.dart';

/// Khoảng cuộn khi ô nhập được chọn ở màn tạo đơn: chừa chỗ cho thanh nút ở đáy (nút
/// "Xong") để ô nhập — nhất là ô Ghi chú nhiều dòng — luôn nằm trên thanh nút và bàn
/// phím, vừa gõ vừa thấy nội dung.
const EdgeInsets kFormFieldScrollPaddingV2 = EdgeInsets.fromLTRB(20, 20, 20, 220);

/// Thanh nút ở đáy màn tạo đơn (đặt ở `Scaffold.bottomSheet`).
///
/// - Bàn phím đang mở: thay các nút Lưu / Gửi bằng nút "Xong" — bấm để đóng bàn phím.
/// - Bàn phím đóng: hiện lại [child] (các nút Lưu / Gửi yêu cầu / Tạo …) ở cuối màn.
///
/// Trước đây các nút nằm ngay trên bàn phím và che mất ô Ghi chú khi đang gõ.
class KeyboardDoneBarV2 extends StatelessWidget {
  final Widget child;
  const KeyboardDoneBarV2({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Scaffold giữ viewInsets (bàn phím) cho bottomSheet nên đọc được ở đây.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (!keyboardOpen) return child;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTokensV2.accent.withValues(alpha: 0.5)),
          ),
          child: Text(
            'Xong',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTokensV2.accent,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
