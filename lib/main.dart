import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pm_app/app/core/logger/logger.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'di/di.dart' as di;
import 'app/core/service/firebase_messaging_service.dart';

final getIt = GetIt.instance;

void main() {
  runZonedGuarded(() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try{
      FirebaseMessagingService.initializeFCM();
    }catch(_){
      logger.d("initilize fcm");
    }


    await di.init();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    runApp(MyApp());
    // FlutterNativeSplash.remove();
  }, (error, stack) {
    debugPrint("Uncaught error: $error");
  });
}
