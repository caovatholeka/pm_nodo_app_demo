import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
  group('Kiểm tra bán kính chấm công (radius tolerance = 0)', () {
    const double radiusTolerance = 0;

    bool isWithinAllowedRadius(double distance, double locationRadius) {
      return distance.round() <= locationRadius.round() + radiusTolerance;
    }

    test('Đứng trong hoặc đúng trên vòng đỏ (<= R) -> cho phép chấm công', () {
      const radius = 50.0;
      expect(isWithinAllowedRadius(0.0, radius), isTrue);
      expect(isWithinAllowedRadius(30.0, radius), isTrue);
      expect(isWithinAllowedRadius(50.0, radius), isTrue);
    });

    test('Đứng ra ngoài vòng đỏ (> R) -> bị chặn ngay lập tức, không còn ăn gian 100m', () {
      const radius = 50.0;
      expect(isWithinAllowedRadius(51.0, radius), isFalse);
      expect(isWithinAllowedRadius(70.0, radius), isFalse);
      expect(isWithinAllowedRadius(120.0, radius), isFalse);
      expect(isWithinAllowedRadius(151.0, radius), isFalse);
    });
  });

  group('Kiểm tra giải trình chấm công muộn/sớm (bắt buộc có nội dung)', () {
    String? validateExplanation(String? val) {
      if (val == null || val.trim().isEmpty) {
        return "Vui lòng nhập giải trình";
      }
      return null;
    }

    test('Không nhập gì hoặc chỉ nhập khoảng trắng -> báo lỗi Vui lòng nhập giải trình', () {
      expect(validateExplanation(null), "Vui lòng nhập giải trình");
      expect(validateExplanation(""), "Vui lòng nhập giải trình");
      expect(validateExplanation("   "), "Vui lòng nhập giải trình");
      expect(validateExplanation("\n\t  "), "Vui lòng nhập giải trình");
    });

    test('Có nội dung giải trình hợp lệ -> cho phép lưu', () {
      expect(validateExplanation("Kẹt xe trên đường Nguyễn Xiển"), isNull);
      expect(validateExplanation(" Đi gặp khách hàng "), isNull);
    });
  });

  group('Widget test: Dialog giải trình muộn/sớm tương tác trên UI', () {
    testWidgets('Bấm Lưu khi ô trống -> không pop dialog, hiện lỗi Vui lòng nhập giải trình', (tester) async {
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
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Vui lòng nhập giải trình";
                                }
                                return null;
                              },
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              final reason = reasonController.text.trim();
                              if (reason.isEmpty) {
                                reasonKey.currentState?.validate();
                                return;
                              }
                              if (reasonKey.currentState?.validate() ?? false) {
                                Navigator.of(ctx).pop(reason);
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

      // 2. Thử nhập toàn dấu cách "   " rồi bấm Lưu
      await tester.enterText(find.byType(TextFormField), "   ");
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Vẫn không đóng, vẫn hiện lỗi
      expect(dialogClosed, isFalse);
      expect(find.text("Vui lòng nhập giải trình"), findsOneWidget);

      // 3. Nhập lý do thật "Kẹt xe" rồi bấm Lưu
      await tester.enterText(find.byType(TextFormField), "Kẹt xe do mưa ngập");
      await tester.tap(find.text("Lưu"));
      await tester.pumpAndSettle();

      // Dialog đóng và trả về đúng lý do
      expect(dialogClosed, isTrue);
      expect(returnedReason, "Kẹt xe do mưa ngập");
    });
  });
}
