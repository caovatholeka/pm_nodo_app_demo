import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/generated/l10n.dart';

/// Dòng ngày / giờ ở mục "Hoạt động" (Dữ liệu công v2).
void main() {
  const at = '2026-10-29 13:48:05';

  test('tiếng Việt: viết hoa chữ đầu, không có dấu cách trước dấu phẩy', () async {
    await S.load(const Locale('vi'));
    expect(AppDateUtils().formatDateTime(at), 'Thứ năm, 29/10/2026');
    expect(AppDateUtils().formatDateTime('2026-11-01 08:00:00'), 'Chủ nhật, 01/11/2026');
  });

  test('tiếng Anh', () async {
    await S.load(const Locale('en'));
    expect(AppDateUtils().formatDateTime(at), 'Thursday, 29/10/2026');
  });

  test('giờ 24h không kèm am/pm', () {
    expect(AppDateUtils().formatTimeHm(at), '13:48');
    expect(AppDateUtils().formatTimeHm('2026-10-29 08:05:00'), '08:05');
  });
}
