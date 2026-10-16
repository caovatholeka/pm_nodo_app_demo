import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/service/local_notification_service.dart';
import 'package:pm_app/app/core/utils/quick_navigator.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/features/ui/auth/login/login_page.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'di/di.dart' as di;
import 'app/core/service/firebase_messaging_service.dart';
import 'app/core/service/fire_base_analystic.dart';
import 'app/core/service/app_bloc_observer.dart';
import 'app/core/theme_v2/theme_controller_v2.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseAnalysticService.initialize();
      await LocalNotificationService.initialize();
      try {
        await FirebaseMessagingService.initializeFCM();
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
        GlobalData.instance.quickActionPending = type;

        if (GlobalData.instance.isLoggingIn) {
          return;
        }

        final token = await SharedPrefsHelper.getToken();

        if (token == null) {
          GlobalData.instance.isFromQuickAction = false;
          GlobalData.instance.navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
          return;
        }

        final nav = GlobalData.instance.navigatorKey.currentState;

        if (nav != null) {
          QuickNavigator.navigate(type);
        } else {
          GlobalData.instance.quickActionPending = type;
        }
      });

      quickActions.setShortcutItems(const <ShortcutItem>[
        ShortcutItem(
          type: 'action_tasks',
          localizedTitle: 'Việc cần làm',
          icon: 'ic_task',
        ),
        ShortcutItem(
          type: 'action_checkin',
          localizedTitle: 'Chấm công',
          icon: 'ic_checkinout',
        ),
        ShortcutItem(
          type: 'action_leave',
          localizedTitle: 'Nghỉ phép',
          icon: 'ic_onleave',
        ),
      ]);

      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      final appEnv = await SharedPrefsHelper.getAppEnv();
      AppConfig.setEnvironment(appEnv);
      await ThemeControllerV2.instance.load();

      final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
      if (mapsImplementation is GoogleMapsFlutterAndroid) {
        mapsImplementation.useAndroidViewSurface = true;
      }

      runApp(MyApp());
    },
    (error, stack) {
      FirebaseAnalysticService.recordError(error, stack, fatal: true);
    },
  );
}
