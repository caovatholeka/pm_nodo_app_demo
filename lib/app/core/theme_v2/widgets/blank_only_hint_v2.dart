import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../app_tokens_v2.dart';

/// Dòng cảnh báo đỏ dưới ô bắt buộc khi người dùng đã gõ nhưng toàn khoảng trắng / ký tự
/// vô hình ([Validator.isBlank]) — kèm việc nút Lưu/Gửi không bấm được, để người dùng biết
/// vì sao. Ô trống hẳn thì không hiện (như trước).
class BlankOnlyHintV2 extends StatelessWidget {
  final TextEditingController controller;

  /// Tên ô trong câu cảnh báo, vd "Ghi chú", "Lý do nghỉ phép".
  final String fieldName;

  const BlankOnlyHintV2({
    super.key,
    required this.controller,
    required this.fieldName,
  });

  static String message(String fieldName) =>
      '$fieldName không được chỉ có khoảng trắng';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        if (text.isEmpty || !Validator.isBlank(text)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            message(fieldName),
            style: TextStyle(
              color: AppTokensV2.danger,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
