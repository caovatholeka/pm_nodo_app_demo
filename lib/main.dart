import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'di/di.dart' as di;

final getIt = GetIt.instance;
void main() {
  runZonedGuarded(() async{
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    await di.init();
    // await FirebaseMessagingService().initialize();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    runApp(MyApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error');
  });
}
