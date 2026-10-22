import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

Color? _sheetColor(WidgetTester tester, Finder sheet) {
  final material = tester.widget<Material>(
    find.descendant(of: sheet, matching: find.byType(Material)).first,
  );
  return material.color;
}

void main() {
  testWidgets('nút ở đáy (Scaffold.bottomSheet): nền khung trong suốt, popup giữ màu cũ',
      (tester) async {
    late BuildContext pageContext;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: BottomSheetBarThemeV2(
        child: Builder(builder: (context) {
          pageContext = context;
          return const Scaffold(
            body: SizedBox.expand(),
            bottomSheet: Padding(padding: EdgeInsets.all(18), child: Text('Lưu')),
          );
        }),
      ),
    ));

    expect(_sheetColor(tester, find.byType(BottomSheet).first), Colors.transparent);

    final defaultModal = ThemeData(useMaterial3: true).colorScheme.surfaceContainerLow;
    showModalBottomSheet<void>(context: pageContext, builder: (_) => const Text('popup'));
    await tester.pumpAndSettle();
    final modal = find.ancestor(of: find.text('popup'), matching: find.byType(BottomSheet));
    expect(_sheetColor(tester, modal), defaultModal);
  });
}
