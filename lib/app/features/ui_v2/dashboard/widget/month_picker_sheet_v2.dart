import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bottom sheet chọn tháng (dark, v2) — thay cho [CupertinoPicker] nền trắng
/// dùng ở các màn chi tiết Dashboard bản gốc (sinh nhật, kỷ luật, chấm công).
/// Trả về tháng đã chọn (1-12), hoặc null nếu người dùng huỷ.
Future<int?> showMonthPickerV2(
  BuildContext context, {
  required int initialMonth,
}) {
  final s = S.of(context);
  int tempMonth = initialMonth;

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppTokensV2.bgTop,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SizedBox(
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Text(
                      s.cancel,
                      style: AppTokensV2.body.copyWith(
                        color: AppTokensV2.fgMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetContext, tempMonth),
                    child: Text(
                      s.day_off_donebtn,
                      style: const TextStyle(
                        color: AppTokensV2.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoPicker(
                  backgroundColor: Colors.transparent,
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialMonth - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    tempMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(
                        '${s.month} ${(i + 1).toString().padLeft(2, '0')}',
                        style: AppTokensV2.body.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
