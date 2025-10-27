import 'dart:async';

class AppEvent {
  AppEvent._privateConstructor();

  static final AppEvent instance = AppEvent._privateConstructor();

  // ignore: close_sinks
  final onTokenExpired = StreamController<bool>.broadcast();
}