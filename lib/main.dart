import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/quick_navigator.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/features/ui/auth/login/login_page.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/repositories/auth_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'firebase_options.dart';

import 'app/app.dart';
import 'di/di.dart' as di;
import 'app/core/service/firebase_messaging_service.dart';

final getIt = GetIt.instance;

void main() {
  runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      try {
        FirebaseMessagingService.initializeFCM();
      } catch (_) {
        logger.d("initilize fcm");
      }

      await di.init();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      const quickActions = QuickActions();
      quickActions.initialize((String type) async {
        final token = await SharedPrefsHelper.getToken();

        if (token == null) {
          GlobalData.instance.quickActionPending = type;
          GlobalData.instance.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          return;
        }

        GlobalData.instance.quickActionPending = null;

        QuickNavigator.navigate(type);
      });

      quickActions.setShortcutItems(<ShortcutItem>[
        const ShortcutItem(
          type: 'action_checkin',
          localizedTitle: 'Chấm công',
          icon: 'ic_checkinout',
        ),
        const ShortcutItem(
          type: 'action_tasks',
          localizedTitle: 'Giao việc',
          icon: 'ic_task',
        ),
        const ShortcutItem(
          type: 'action_leave',
          localizedTitle: 'Nghỉ phép',
          icon: 'ic_onleave',
        ),
      ]);

      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (_) => AppCubit(
                    authRepository: getIt<AuthRepository>(),
                    userRepository: getIt<UserRepository>(),
                  )..countUnreadNoti(),
            ),
          ],
          child: MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint("Uncaught error: $error");
    },
  );
}
