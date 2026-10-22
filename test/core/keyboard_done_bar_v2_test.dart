import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/theme_v2/widgets/keyboard_done_bar_v2.dart';

/// Màn giả lập giống các màn tạo đơn v2: form cuộn (đệm đáy 120) + ô Ghi chú ở cuối +
/// nút Lưu ở Scaffold.bottomSheet.
Widget _form(TextEditingController note, FocusNode focus) {
  return MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          child: Column(children: [
            for (var i = 0; i < 8; i++)
              const SizedBox(height: 70, child: Text('Trường khác')),
            TextField(
              key: const Key('note'),
              focusNode: focus,
              controller: note,
              maxLines: 6,
              scrollPadding: kFormFieldScrollPaddingV2,
            ),
          ]),
        ),
      ),
      bottomSheet: KeyboardDoneBarV2(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: ElevatedButton(onPressed: () {}, child: const Text('Lưu')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('bàn phím đóng → nút Lưu; mở → nút "Xong", bấm Xong thì đóng bàn phím',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final note = TextEditingController();
    final focus = FocusNode();
    await tester.pumpWidget(_form(note, focus));
    expect(find.text('Lưu'), findsOneWidget);
    expect(find.text('Xong'), findsNothing);

    // Chọn ô Ghi chú + bàn phím bật lên (300 dp)
    await tester.tap(find.byKey(const Key('note')), warnIfMissed: false);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(find.text('Xong'), findsOneWidget);
    expect(find.text('Lưu'), findsNothing);

    // Ô Ghi chú nằm trọn trên thanh nút "Xong" (không bị che)
    final noteRect = tester.getRect(find.byKey(const Key('note')));
    final barTop = tester.getRect(find.byType(KeyboardDoneBarV2)).top;
    expect(noteRect.bottom <= barTop, isTrue,
        reason: 'ô ghi chú $noteRect bị thanh nút (top $barTop) che');

    // Bấm Xong → bỏ chọn ô nhập (bàn phím đóng) → hiện lại nút Lưu
    await tester.tap(find.text('Xong'));
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isFalse);
    expect(find.text('Lưu'), findsOneWidget);
    expect(find.text('Xong'), findsNothing);
  });
}
