import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';

import '../../../core/router/application.dart';
import '../../../core/router/routers.dart';
import 'splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _cubit = GetIt.I.get<SplashCubit>();
  StreamSubscription? _navigationSubscription;

  @override
  void initState() {
    super.initState();
    _initData();
    _navigationSubscription = _cubit.navigatorController.stream.listen((event) {
      // Trước đây chờ cứng 1 giây ở đây — chỉ làm app vào chậm thêm 1s mà không
      // đem lại gì. Điều hướng ngay khi biết trạng thái đăng nhập.
      FlutterNativeSplash.remove();
      switch (event) {
        case SplashNavigator.OPEN_HOME:
          showHome();
          break;
        case SplashNavigator.OPEN_LOG_IN:
          showLogIn();
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _navigationSubscription?.cancel();
    _cubit.close();
  }

  void _initData() async {
    //Request permission
    // await firebaseMessaging.requestPermission();
    // await firebaseMessaging.getToken().then((value) {
    //   _cubit.getDevicesToken(value ?? "");
    // });

    _cubit.checkLogin();
  }

  void showLogIn() async {
    Application.router.navigateTo(context, Routes.login, clearStack: true);
  }

  void showHome() {
    Application.router.navigateTo(context, Routes.home, clearStack: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
