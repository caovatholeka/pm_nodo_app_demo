import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Giống lib/app/app.dart: dùng bộ ngôn ngữ chuẩn của Flutter (có sẵn trong SDK).
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui_v2/overtime/create_overtime_v2.dart';
import 'package:pm_app/app/features/ui_v2/task/create_new_task_v2.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

class _TaskRepo extends Fake implements TaskRepository {
  @override
  Future<CommonResponse> getListUser() async => CommonResponse(data: const []);
}

class _OtRepo extends Fake implements OvertimeRepository {}

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('vi'),
      home: child,
    );

/// TextField (bên trong TextFormField/InputTextField) có maxLength = [max].
Finder _fieldWithMax(int max) => find.byWidgetPredicate(
    (w) => w is TextField && w.maxLength == max,
    description: 'TextField maxLength=$max');

void main() {
  test('giới hạn khớp backend (nodo_hr_api/handler/input_limits.py)', () {
    expect(InputLimits.taskTitle, 255);
    expect(InputLimits.taskDescription, 2000);
    expect(InputLimits.requestNote, 1000);
    expect(InputLimits.address, 255);
    expect(InputLimits.checkInReason, 500);
  });

  group('inputCounterV2', () {
    Widget? counter(InputCounterWidgetBuilder b, int len, int max) => b(
        _FakeContext(),
        currentLength: len,
        maxLength: max,
        isFocused: true);

    test('ô nhiều dòng: luôn hiện "n/max"', () {
      final w = counter(inputCounterV2(), 0, 1000) as Text;
      expect(w.data, '0/1000');
    });
    test('ô 1 dòng: chỉ hiện khi đã gõ từ 80%', () {
      expect(counter(inputCounterV2(always: false), 203, 255), isNull);
      expect((counter(inputCounterV2(always: false), 204, 255) as Text).data, '204/255');
    });
    test('chạm giới hạn → số màu đỏ', () {
      final w = counter(inputCounterV2(), 1000, 1000) as Text;
      expect(w.style?.color, AppTokensV2.danger);
    });
  });

  testWidgets('InputTextField: không gõ quá maxLength, hiện bộ đếm', (tester) async {
    final ctrl = TextEditingController();
    await tester.pumpWidget(_app(Scaffold(
      body: InputTextField(
        hintText: '',
        isRequiredField: true,
        controller: ctrl,
        maxLength: 500,
        buildCounter: inputCounterV2(),
      ),
    )));
    await tester.enterText(find.byType(TextField), 'x' * 600);
    await tester.pump();
    expect(ctrl.text.length, 500);
    expect(find.text('500/500'), findsOneWidget);
  });

  group('Màn thật', () {
    setUp(() async {
      await GetIt.instance.reset();
      GetIt.instance.registerFactory<TaskCubit>(() => TaskCubit(repository: _TaskRepo()));
      GetIt.instance.registerSingleton<OvertimeRepository>(_OtRepo());
    });

    testWidgets('Tạo việc cần làm: tiêu đề tối đa 255, mô tả tối đa 2000', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(CreateNewTaskV2()));
      await tester.pump(const Duration(milliseconds: 300));

      final title = _fieldWithMax(InputLimits.taskTitle);
      final desc = _fieldWithMax(InputLimits.taskDescription);
      expect(title, findsOneWidget);
      expect(desc, findsOneWidget);

      await tester.enterText(title, 'T' * 300);
      await tester.pump();
      expect(tester.widget<TextField>(title).controller!.text.length, 255);
      expect(find.text('255/255'), findsOneWidget); // ô 1 dòng: hiện khi gần đầy

      await tester.enterText(desc, 'D' * 2100);
      await tester.pump();
      expect(tester.widget<TextField>(desc).controller!.text.length, 2000);
      expect(find.text('2000/2000'), findsOneWidget);
    });

    testWidgets('Tạo đơn OT: lý do tối đa 1000 và có bộ đếm', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const CreateOTPageV2()));
      await tester.pump(const Duration(milliseconds: 300));

      final note = _fieldWithMax(InputLimits.requestNote);
      expect(note, findsOneWidget);
      expect(find.text('0/1000'), findsOneWidget);
      await tester.enterText(note, 'Lý do ' * 300); // 1800 ký tự
      await tester.pump();
      expect(tester.widget<TextField>(note).controller!.text.characters.length, 1000);
      expect(find.text('1000/1000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeContext extends Fake implements BuildContext {}
