import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/features/ui/checkin/widget/location_status_chip.dart';
import 'package:pm_app/generated/l10n.dart';

Widget _wrap(Widget child, {double width = 320}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: width, child: child)),
    ),
  );
}

void main() {
  test('formatDistance: m dưới 1 km, km dùng dấu phẩy với tiếng Việt', () {
    expect(formatDistance(30.33, 'vi'), '30 m');
    expect(formatDistance(999.4, 'vi'), '999 m');
    expect(formatDistance(1234, 'vi'), '1,2 km');
    expect(formatDistance(1234, 'en'), '1.2 km');
  });

  // 288 = bề ngang nội dung trên màn hẹp nhất còn dùng (iPhone SE 320pt trừ 2 lề 16)
  for (final (status, expected) in [
    (LocationStatus.locating, 'Đang định vị…'),
    (LocationStatus.weakSignal, 'Tín hiệu GPS yếu (±250 m)'),
    (LocationStatus.inRange, 'Trong phạm vi · cách 30 m'),
    (LocationStatus.outOfRange, 'Ngoài phạm vi · cách 12,3 km'),
  ]) {
    testWidgets('chip $status hiển thị đúng chữ, không tràn ở màn hẹp', (tester) async {
      await tester.pumpWidget(_wrap(
        LocationStatusChip(
          status: status,
          distanceMeters: status == LocationStatus.outOfRange ? 12345 : 30,
          accuracyMeters: 250,
        ),
        width: 288,
      ));
      await tester.pump();
      expect(find.text(expected), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
