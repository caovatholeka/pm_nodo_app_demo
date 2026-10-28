import 'package:flutter/material.dart';
import '../app_tokens_v2.dart';

/// Bộ đếm ký tự "n/max" dưới ô nhập có giới hạn (`TextField.buildCounter`).
///
/// - [always] = true (ô nhiều dòng: mô tả, lý do, ghi chú): luôn hiện.
/// - [always] = false (ô 1 dòng: tiêu đề, địa chỉ): chỉ hiện khi đã gõ từ 80% giới hạn,
///   cho gọn mà người dùng vẫn biết vì sao không gõ thêm được.
/// Chạm giới hạn thì số chuyển màu đỏ. [style] mặc định là chữ phụ v2 (theo theme sáng/tối).
InputCounterWidgetBuilder inputCounterV2({bool always = true, TextStyle? style}) {
  return (
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) {
    if (maxLength == null) return null;
    if (!always && currentLength < maxLength * 0.8) return null;
    final base = style ?? AppTokensV2.caption;
    return Text(
      '$currentLength/$maxLength',
      style: currentLength >= maxLength
          ? base.copyWith(color: AppTokensV2.danger)
          : base,
    );
  };
}
