import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_it/get_it.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pm_app/app/core/utils/quick_navigator.dart';
import 'package:pm_app/app/data/repositories/employee_repository.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_cubit.dart';
import 'package:pm_app/app/features/ui/auth/forgot_pass/forgot_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/staff/bottom_sheet/employee_filter_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:provider/single_child_widget.dart';

import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/generated/l10n.dart';

import '../di/di.dart';
import 'config/app_config.dart';
import 'config/app_event.dart';
import 'core/commons/app_theme.dart';
import 'core/commons/global_data.dart';
import 'core/logger/logger.dart';
import 'core/router/application.dart';
import 'core/router/routers.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/work_entry_repository.dart';
import 'features/bloc/app_cubit.dart';
import 'features/ui/attendance/attendance_data_tab/explanation_tab/explanation_cubit.dart';
import 'features/ui/attendance/explanation/explanation_list_cubit.dart';
import 'features/ui/auth/login/login_cubit.dart';
import 'features/ui/checkin/bloc/face_scan_cubit.dart';
import 'features/ui/splash/splash_cubit.dart';
import 'features/ui/account/account_cubit.dart';

final getIt = GetIt.instance;

class MyApp extends StatefulWidget {
  MyApp({super.key}) {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  OverlaySupportEntry? _overlaySupportEntry;
  bool networkEnabled = true;

  final _appCubit = sl<AppCubit>();
  Locale? _locale;

  StreamSubscription<bool>? _serverBusySubscription;
  bool _isShowingServerBusyDialog = false;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _loadSavedLanguage();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    _listenServerBusyEvent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = GlobalData.instance.quickActionPending;
      if (pending != null &&
          GlobalData.instance.navigatorKey.currentState != null) {
        QuickNavigator.navigate(pending);
        GlobalData.instance.quickActionPending = null;
      }
    });
  }

  Future<void> _loadSavedLanguage() async {
    final savedLang = await SharedPrefsHelper.getAppLanguage();
    setState(() {
      _locale = Locale(savedLang);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _serverBusySubscription?.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      logger.d(e.toString());
      return;
    }

    if (!mounted) return;

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results[0];
    if (result != ConnectivityResult.wifi &&
        result != ConnectivityResult.mobile) {
      if (networkEnabled) {
        _overlaySupportEntry = showSimpleNotification(
          const Text('Mất kết nối, vui lòng kiểm tra lại đường truyền.'),
          leading: const Icon(Icons.wifi, color: Colors.white),
          autoDismiss: false,
          background: Colors.red,
        );
      }
      networkEnabled = false;
    } else {
      networkEnabled = true;
      _overlaySupportEntry?.dismiss(animate: true);
    }
  }

  void _listenServerBusyEvent() {
    _serverBusySubscription = AppEvent.instance.onServerBusy.stream.listen((event) {
      if (!event || !mounted || _isShowingServerBusyDialog) return;

      final currentContext = GlobalData.instance.navigatorKey.currentContext;
      if (currentContext == null) return;

      _isShowingServerBusyDialog = true;

      showDialog(
        context: currentContext,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => CustomDialog(
          title: "Thông báo",
          content: "Server đang bận hoặc hệ thống đang gặp sự cố. Bạn có muốn quay về màn hình đăng nhập không?",
          success: false,
          confirmText: "OK",
          cancelText: "Cancel",
          onConfirm: () async {
            Navigator.of(currentContext, rootNavigator: true).pop();
            _isShowingServerBusyDialog = false;

            await SharedPrefsHelper.saveToken(null);
            GlobalData.instance.token = null;

            GlobalData.instance.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              Routes.login,
                  (route) => false,
            );
          },
          onCancel: () {
            Navigator.of(currentContext, rootNavigator: true).pop();
            _isShowingServerBusyDialog = false;
          },
        ),
      ).then((_) {
        _isShowingServerBusyDialog = false;
      });
    });
  }

  List<SingleChildWidget> _buildBlocProviders() {
    return [
      BlocProvider(create: (context) => sl<AppCubit>()),
      BlocProvider(create: (context) => sl<NotiCubit>()..countUnreadNoti()),
      BlocProvider(create: (context) => sl<SplashCubit>()),
      BlocProvider(create: (context) => sl<OnLeaveCubit>()),
      BlocProvider(create: (context) => sl<CreateOnLeaveCubit>()),
      BlocProvider(create: (context) => sl<LogInCubit>()),
      BlocProvider(create: (context) => sl<StaffCubit>()),
      BlocProvider(create: (context) => sl<AccountCubit>()),
      BlocProvider(create: (context) => sl<EmployeeFilterCubit>()),
      BlocProvider(create: (context) => sl<AttendanceDataCubit>()),
      BlocProvider(create: (context) => sl<ForgotCubit>()),
      BlocProvider(create: (context) => sl<ExplanationCubit>()),
      BlocProvider(create: (context) => sl<ExplanationListCubit>()),
      BlocProvider(create: (context) => sl<FaceScanCubit>()),
      BlocProvider(create: (context) => sl<TaskCubit>()),
      BlocProvider(create: (context) => sl<CreateAppraisalCubit>()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => sl<AuthRepository>()),
        RepositoryProvider(create: (context) => sl<OnLeaveRepository>()),
        RepositoryProvider(create: (context) => sl<EmployeeRepository>()),
        RepositoryProvider(create: (context) => sl<WorkEntryRepository>()),
        RepositoryProvider(create: (context) => sl<UserRepository>()),
        RepositoryProvider(create: (context) => sl<TaskRepository>()),
        RepositoryProvider(create: (context) => sl<JutificationRepository>()),
        RepositoryProvider(create: (context) => sl<OvertimeRepository>()),
      ],
      child: MultiBlocProvider(
        providers: _buildBlocProviders(),
        child: BlocConsumer<AppCubit, AppState>(
          listenWhen:
              (prev, curr) =>
                  prev.tokenExpired != curr.tokenExpired &&
                  curr.tokenExpired == true,

          listener: (context, state) {
            showDialog(
              context: context,
              barrierDismissible: false,
              useRootNavigator: true,
              builder:
                  (_) => CustomDialog(
                    title: "Phiên đăng nhập đã hết hạn",
                    content:
                        "Phiên làm việc của bạn đã hết hạn. Vui lòng đăng nhập lại để tiếp tục sử dụng.",
                    success: false,
                    confirmText: "Đăng nhập lại",
                    cancelText: "Thoát",
                    onConfirm: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.read<AppCubit>().resetTokenExpired();
                      await SharedPrefsHelper.saveToken(null);
                      GlobalData.instance.navigatorKey.currentState
                          ?.pushNamedAndRemoveUntil(
                            Routes.login,
                            (route) => false,
                          );
                    },

                    onCancel: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.read<AppCubit>().resetTokenExpired();
                    },
                  ),
            );
          },

          buildWhen: (pre, cur) => pre.locale != cur.locale,

          builder: (context, state) {
            return OverlaySupport(child: materialApp(state.locale ?? _locale));
          },
        ),
      ),
    );
  }

  GetMaterialApp materialApp(Locale? locale) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppThemes.theme,
      navigatorKey: GlobalData.instance.navigatorKey,
      onGenerateRoute: Application.router.generator,
      initialRoute: Routes.root,

      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      builder: (context, child) {
        return GestureDetector(
          onTap: () => hideKeyboard(context),
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          ),
        );
      },
    );
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
