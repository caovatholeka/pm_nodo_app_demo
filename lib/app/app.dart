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
import 'package:pm_app/app/data/repositories/employee_repository.dart';
import 'package:pm_app/app/data/repositories/on_leave_repository.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/on_leave/bloc/on_leave_cubit.dart';
import 'package:pm_app/app/features/ui/staff/bottom_sheet/employee_filter_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:provider/single_child_widget.dart';

import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/generated/l10n.dart';

import '../di/di.dart';
import 'config/app_config.dart';
import 'core/commons/app_theme.dart';
import 'core/commons/global_data.dart';
import 'core/logger/logger.dart';
import 'core/router/application.dart';
import 'core/router/routers.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/employee_repository.dart';
import 'data/repositories/on_leave_repository.dart';
import 'features/bloc/app_cubit.dart';
import 'features/ui/auth/login/login_cubit.dart';
import 'features/ui/on_leave/bloc/create_on_leave_cubit.dart';
import 'features/ui/on_leave/bloc/on_leave_cubit.dart';
import 'features/ui/splash/splash_cubit.dart';
import 'features/ui/account/account_cubit.dart';
import 'features/ui/staff/staff_cubit.dart';

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

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _loadSavedLanguage();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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

  List<SingleChildWidget> _buildBlocProviders() {
    return [
      BlocProvider(create: (context) => sl<AppCubit>()),
      BlocProvider(create: (context) => sl<SplashCubit>()),
      BlocProvider(create: (context) => sl<OnLeaveCubit>()),
      BlocProvider(create: (context) => sl<CreateOnLeaveCubit>()),
      BlocProvider(create: (context) => sl<LogInCubit>()),
      BlocProvider(create: (context) => sl<StaffCubit>()),
      BlocProvider(create: (context) => sl<AccountCubit>()),
      BlocProvider(create: (context) => sl<EmployeeFilterCubit>()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => sl<AuthRepository>()),
        RepositoryProvider(create: (context) => sl<OnLeaveRepository>()),
        RepositoryProvider(create: (context) => sl<EmployeeRepository>()),
      ],
      child: MultiBlocProvider(
        providers: _buildBlocProviders(),
        child: BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {},
          buildWhen: (pre, cur) => pre.locale != cur.locale,
          builder: (context, state) {
            return OverlaySupport(child: materialApp(state.locale ?? _locale));
          },
        ),
      ),
    );
  }

  GetMaterialApp materialApp(Locale? locale) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
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
