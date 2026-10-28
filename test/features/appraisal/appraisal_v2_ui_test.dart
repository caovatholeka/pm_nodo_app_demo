import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Giống lib/app/app.dart: dùng bộ ngôn ngữ chuẩn của Flutter (có sẵn trong SDK).
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/theme_controller_v2.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/auth_repository.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/apprasial_form_cubit.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/appraisal_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/detail_appraisal_form_v2.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

class _EvalRepo extends Fake implements EvaluationRepository {
  @override
  Future<CommonResponse> getListEvaluation(
          String? dateForm, String? dateTo, int limit, int page) async =>
      CommonResponse(data: const []);
}

class _Auth extends Fake implements AuthRepository {}

class _User extends Fake implements UserRepository {}

Color? _titleColor(WidgetTester tester, String title) =>
    tester.widget<Text>(find.text(title)).style?.color;

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('vi'),
      home: Scaffold(body: child),
    );

void main() {
  setUp(() => ThemeControllerV2.instance.mode.value = ThemeModeV2.dark);

  group('InputTextField v2Style (Tạo phiếu đánh giá, theme tối)', () {
    testWidgets('tiêu đề, dấu *, icon lịch dùng màu v2 sáng trên nền tối',
        (tester) async {
      await tester.pumpWidget(_app(InputTextField(
        v2Style: true,
        title: 'Mã nhân viên',
        hintText: '',
        isRequiredField: true,
        readOnly: true,
        suffixIcon: AppAssets.icCalendar,
      )));

      // Trước: AppColors.gray (#262626) gần như trùng nền tối.
      expect(_titleColor(tester, 'Mã nhân viên'), AppTokensV2.fgMuted);
      expect(AppTokensV2.fgMuted, PaletteV2.dark.fgMuted);
      expect(find.text('*'), findsOneWidget);
      expect(tester.widget<Text>(find.text('*')).style?.color, AppTokensV2.danger);

      final icon = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(icon.colorFilter,
          ColorFilter.mode(AppTokensV2.fgSoft, BlendMode.srcIn));

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.color, AppTokensV2.fg);
      expect(field.decoration?.fillColor, AppTokensV2.surfaceStrong);
    });

    testWidgets('không bật v2Style → giữ nguyên kiểu cũ (màn v1, popup nền trắng)',
        (tester) async {
      await tester.pumpWidget(_app(InputTextField(
        title: 'Lý do',
        hintText: '',
        isRequiredField: true,
      )));
      expect(_titleColor(tester, 'Lý do'), AppColors.gray);
      expect(find.text('*'), findsNothing); // vẫn dùng icon sao SVG như cũ
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.color, Colors.black);
      expect(field.decoration?.fillColor, Colors.white);
    });
  });

  group('Phiếu đánh giá có nút quay lại', () {
    setUp(() async {
      await GetIt.instance.reset();
      GetIt.instance.registerLazySingleton<ApprasialFormCubit>(
          () => ApprasialFormCubit(repository: _EvalRepo()));
    });

    Future<void> openFromMenu(WidgetTester tester, Widget page) async {
      await tester.pumpWidget(BlocProvider(
        create: (_) => AppCubit(authRepository: _Auth(), userRepository: _User()),
        child: _app(Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => page)),
            child: const Text('Đơn từ'),
          ),
        )),
      ));
      await tester.tap(find.text('Đơn từ'));
      await tester.pumpAndSettle();
    }

    testWidgets('mở từ Đơn từ → có nút quay lại, bấm thì về Đơn từ',
        (tester) async {
      await openFromMenu(tester, const AppraisalPageV2(isFromHome: true));
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AppraisalPageV2), findsNothing);
      expect(find.text('Đơn từ'), findsOneWidget);
    });

    testWidgets('không truyền isFromHome nhưng mở bằng push → vẫn có nút quay lại',
        (tester) async {
      await openFromMenu(tester, const AppraisalPageV2());
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  testWidgets('Màn Tạo phiếu đánh giá (theme tối): mọi tiêu đề ô nhập dùng màu v2, không lỗi layout',
      (tester) async {
    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<EvaluationRepository>(_EvalRepo());
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const DetailAppraisalFormV2()));
    await tester.pump(const Duration(milliseconds: 500));

    for (final title in ['Mã nhân viên', 'Tên nhân viên', 'Phòng ban', 'Từ ngày', 'Đến ngày']) {
      final labels = find.text(title);
      expect(labels, findsWidgets, reason: title);
      // Tiêu đề phía trên ô (không tính chữ gợi ý trong ô) phải là màu v2, không phải #262626.
      final colors = tester.widgetList<Text>(labels).map((t) => t.style?.color).toSet();
      expect(colors.contains(AppColors.gray), isFalse, reason: '$title còn màu cũ');
      expect(colors.contains(AppTokensV2.fgMuted), isTrue, reason: title);
    }
    expect(tester.takeException(), isNull);
  });
}
