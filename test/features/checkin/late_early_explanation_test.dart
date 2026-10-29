import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  // Validator dùng S.current (l10n) → nạp ngôn ngữ vi trước khi gọi trực tiếp.
  setUpAll(() async => S.load(const Locale('vi')));

  group('Kiểm tra bán kính chấm công (radius tolerance = 0)', () {
    const double radiusTolerance = 0;

    bool isWithinAllowedRadius(double distance, double locationRadius) {
      return distance <= locationRadius + radiusTolerance;
    }

    test('Đứng trong hoặc đúng trên vòng đỏ (<= R) -> cho phép chấm công', () {
      const radius = 50.0;
      expect(isWithinAllowedRadius(0.0, radius), isTrue);
      expect(isWithinAllowedRadius(30.0, radius), isTrue);
      expect(isWithinAllowedRadius(50.0, radius), isTrue);
    });

    test('Đứng ra ngoài vòng đỏ (> R) -> bị chặn ngay lập tức, không còn ăn gian 100m hay làm tròn', () {
      const radius = 50.0;
      expect(isWithinAllowedRadius(50.1, radius), isFalse);
      expect(isWithinAllowedRadius(51.0, radius), isFalse);
      expect(isWithinAllowedRadius(70.0, radius), isFalse);
      expect(isWithinAllowedRadius(120.0, radius), isFalse);
      expect(isWithinAllowedRadius(151.0, radius), isFalse);
    });

    test('Khu vực Citi Sport Avenue (~115m) so với điểm Audi Phạm Hùng (bán kính 100m) -> chặn hoàn toàn', () {
      const officeRadius = 100.0;
      const citiSportDist = 114.85;
      expect(isWithinAllowedRadius(citiSportDist, officeRadius), isFalse);
    });
  });

  group('Kiểm tra Validator.isBlank và validateExplanation (bảo vệ chống mọi loại khoảng trắng)', () {
    test('Không nhập gì hoặc chỉ nhập khoảng trắng thường -> báo lỗi Vui lòng nhập giải trình', () {
      expect(Validator.validateExplanation(null), "Vui lòng nhập giải trình");
      expect(Validator.validateExplanation(""), "Vui lòng nhập giải trình");
      expect(Validator.validateExplanation("   "), "Vui lòng nhập giải trình");
      expect(Validator.validateExplanation("\n\t  "), "Vui lòng nhập giải trình");
    });

    test('Nhập khoảng trắng Unicode đặc biệt (zero-width space, non-breaking space, BOM, joiner...) -> chặn tuyệt đối', () {
      // \u200B: Zero-width space
      expect(Validator.isBlank("\u200B"), isTrue);
      expect(Validator.validateExplanation("\u200B"), "Vui lòng nhập giải trình");

      // \u00A0: Non-breaking space
      expect(Validator.isBlank("\u00A0"), isTrue);
      expect(Validator.validateExplanation("\u00A0"), "Vui lòng nhập giải trình");

      // \u200C / \u200D: Zero-width non-joiner / joiner
      expect(Validator.isBlank("\u200C"), isTrue);
      expect(Validator.isBlank("\u200D"), isTrue);
      expect(Validator.validateExplanation("\u200C\u200D"), "Vui lòng nhập giải trình");

      // \uFEFF: Zero-width no-break space / BOM
      expect(Validator.isBlank("\uFEFF"), isTrue);
      expect(Validator.validateExplanation("\uFEFF"), "Vui lòng nhập giải trình");

      // Tổ hợp phím cách trên bàn phím điện thoại (space + zero-width)
      expect(Validator.isBlank("  \u200B  "), isTrue);
      expect(Validator.validateExplanation("  \u200B  "), "Vui lòng nhập giải trình");
      expect(Validator.isBlank("\u00A0 \u200C \u200D \uFEFF "), isTrue);
      expect(Validator.validateExplanation("\u00A0 \u200C \u200D \uFEFF "), "Vui lòng nhập giải trình");
    });

    test('Có nội dung giải trình hợp lệ -> cho phép lưu', () {
      expect(Validator.validateExplanation("Kẹt xe trên đường Nguyễn Xiển"), isNull);
      expect(Validator.validateExplanation(" Đi gặp khách hàng "), isNull);
      expect(Validator.validateExplanation(" \u200BĐi gặp đối tác\u200B "), isNull);
      expect(Validator.cleanWhitespace(" \u200BĐi gặp đối tác\u200B "), "Đi gặp đối tác");
    });
  });

  group('Widget test: Dialog giải trình muộn/sớm tương tác trên UI', () {
    testWidgets('Bấm Lưu khi ô trống hoặc toàn khoảng trắng/zero-width space -> không pop dialog, hiện lỗi', (tester) async {
      String? returnedReason;
      bool dialogClosed = false;

      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            final reasonController = TextEditingController();
            final reasonKey = GlobalKey<FormState>();

            final res = await showDialog<String?>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                return PopScope(
                  canPop: false,
                  child: Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                            key: reasonKey,
                            child: InputTextField(
                              hintText: "Nhập lý do...",
                              isRequiredField: true,
                              controller: reasonController,
                              validator: (val) => Validator.validateExplanation(val),
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              final rawReason = reasonController.text;
                              if (Validator.isBlank(rawReason)) {
                                reasonKey.currentState?.validate();
                                return;
                              }
                              if (reasonKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop(Validator.cleanWhitespace(rawReason));
                              }
                            },
                            child: const Text("Lưu"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
            returnedReason = res;
            dialogClosed = true;
          },
          child: const Text("Mở dialog"),
        );
      })));

      // Mở dialog
      await tester.tap(find.text("Mở dialog"));
      await tester.pumpAndSettle();

      // Kiểm tra dialog đang hiển thị
      expect(find.text("Lưu"), findsOneWidget);

      // 1. Thử bấm "Lưu" khi chưa nhập gì
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Dialog KHÔNG được đóng, lỗi hiển thị
      expect(dialogClosed, isFalse);
      expect(find.text("Vui lòng nhập giải trình"), findsOneWidget);

      // 2. Thử nhập toàn dấu cách thường "   " rồi bấm Lưu
      await tester.enterText(find.byType(TextFormField), "   ");
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Vẫn không đóng, vẫn hiện lỗi
      expect(dialogClosed, isFalse);
      expect(find.text("Vui lòng nhập giải trình"), findsOneWidget);

      // 3. Thử nhập khoảng trắng điện thoại Unicode zero-width space "\u200B"
      await tester.enterText(find.byType(TextFormField), "  \u200B  ");
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Vẫn không đóng, vẫn hiện lỗi
      expect(dialogClosed, isFalse);
      expect(find.text("Vui lòng nhập giải trình"), findsOneWidget);

      // 4. Nhập lý do thật "Kẹt xe" rồi bấm Lưu
      await tester.enterText(find.byType(TextFormField), "Kẹt xe do mưa ngập");
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Dialog đóng và trả về đúng lý do đã clean
      expect(dialogClosed, isTrue);
      expect(returnedReason, "Kẹt xe do mưa ngập");
    });
  });
}
