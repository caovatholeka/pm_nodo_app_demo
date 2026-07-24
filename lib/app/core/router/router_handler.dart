import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../../features/navigation/bottom_navigation.dart';
import '../../features/ui/auth/login/login_page.dart';
import '../../features/ui/splash/splash_page.dart';
import '../../features/ui_v2/auth/login_page_v2.dart';
import '../commons/app_flags.dart';

Handler notHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
      Scaffold(
        body: Center(
          child: Text('$params'),
        ),
      ),
);

Handler splashHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
      SplashPage(),
);

Handler loginHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
      AppFlags.isBetaUiActive() ? const LoginPageV2() : LoginPage(),
);

Handler bottomNavHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) =>
      BottomNavigation(),
);