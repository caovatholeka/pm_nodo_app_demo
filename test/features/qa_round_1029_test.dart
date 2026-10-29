// Kiểm thử theo danh sách lỗi QA 29/10: ô bắt buộc chỉ toàn khoảng trắng, màu chữ màn
// chi tiết ngày công (Dữ liệu chấm công) ở theme tối.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Giống lib/app/app.dart: dùng bộ ngôn ngữ chuẩn của Flutter (có sẵn trong SDK).
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/theme_controller_v2.dart';
import 'package:pm_app/app/core/utils/validators.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui_v2/attendance/widget/detail_work_entry_bottom_sheet_v2.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/create_new_leave_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/overtime/create_overtime_v2.dart';
import 'package:pm_app/app/features/ui_v2/task/create_new_task_v2.dart';
import 'package:pm_app/generated/l10n.dart';

class _TaskRepo extends Fake implements TaskRepository {
  @override
  Future<CommonResponse> getListUser() async => CommonResponse(data: const []);
}

class _OtRepo extends Fake implements OvertimeRepository {}

class _LeaveRepo extends Fake implements OnLeaveRepository {
  @override
  Future<CommonResponse> getListLeavesType() async => CommonResponse(data: const []);
}

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

Finder _fieldWithMax(int max) =>
    find.byWidgetPredicate((w) => w is TextField && w.maxLength == max);

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() async {
    ThemeControllerV2.instance.mode.value = ThemeModeV2.dark;
    await GetIt.instance.reset();
    GetIt.instance.registerFactory<TaskCubit>(() => TaskCubit(repository: _TaskRepo()));
    GetIt.instance.registerSingleton<OvertimeRepository>(_OtRepo());
    GetIt.instance.registerLazySingleton<CreateOnLeaveCubit>(
        () => CreateOnLeaveCubit(repository: _LeaveRepo()));
  });

  group('Ô bắt buộc chỉ toàn khoảng trắng', () {
    test('Validator: khoảng trắng / ký tự vô hình tính là trống', () {
      expect(Validator.validateNotBlank('   '), '');
      expect(Validator.validateNotBlank('​ '), '');
      expect(Validator.validateNotBlank(' Họp khách hàng '), isNull);
    });

    test('Đơn OT: ghi chú chỉ khoảng trắng → không gửi được (trước đây gửi được)', () {
      final base = CreateOvertimeState.initial().copyWith(
        fromDate: '2026-11-02',
        toDate: '2026-11-02',
        overtimeLines: [OvertimeLineEntity(date: '2026-11-02', overtime: 1, formType: 'pay')],
      );
      expect(base.copyWith(note: '    ').isFormValid, isFalse);
      expect(base.copyWith(note: '​').isFormValid, isFalse);
      expect(base.isFormValid, isFalse); // chưa nhập ghi chú
      expect(base.copyWith(note: 'Hỗ trợ triển khai').isFormValid, isTrue);
    });

    testWidgets('Tạo đơn OT: gõ toàn khoảng trắng → hiện cảnh báo đỏ', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_app(const CreateOTPageV2()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(_fieldWithMax(InputLimits.requestNote), '     ');
      await tester.pump();
      expect(find.text('Ghi chú không được chỉ có khoảng trắng'), findsOneWidget);

      await tester.enterText(_fieldWithMax(InputLimits.requestNote), 'Làm thêm dự án A');
      await tester.pump();
      expect(find.text('Ghi chú không được chỉ có khoảng trắng'), findsNothing);
    });

    testWidgets('Tạo nghỉ phép: lý do toàn khoảng trắng → cảnh báo, không bật nút Lưu',
        (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_app(CreateNewLeavePageV2()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(_fieldWithMax(InputLimits.requestNote), '   ');
      await tester.pump();
      expect(find.text('Lý do nghỉ phép không được chỉ có khoảng trắng'), findsOneWidget);
    });

    testWidgets('Tạo việc cần làm: tiêu đề toàn khoảng trắng → cảnh báo', (tester) async {
      await _phone(tester);
      await tester.pumpWidget(_app(CreateNewTaskV2()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(_fieldWithMax(InputLimits.taskTitle), '    ');
      await tester.pump();
      expect(find.text('Tiêu đề không được chỉ có khoảng trắng'), findsOneWidget);
    });
  });

  testWidgets('Dữ liệu chấm công → chi tiết ngày: nhãn dùng màu v2 sáng trên nền tối',
      (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_app(Scaffold(
      body: DetailWorkEntryBottomSheetV2(
        workEntity: WorkEntity(workEntryLabel: 'X', dateStart: '', dateStop: ''),
        date: '2026-10-20',
      ),
    )));
    await tester.pump();
    for (final label in ['Tên', 'Chấm công vào', 'Ca làm việc']) {
      final colors =
          tester.widgetList<Text>(find.text(label)).map((t) => t.style?.color).toSet();
      expect(colors.contains(AppColors.gray), isFalse, reason: '$label còn màu tối cũ');
      expect(colors.contains(AppTokensV2.fgMuted), isTrue, reason: label);
    }
    expect(tester.takeException(), isNull);
  });
}
