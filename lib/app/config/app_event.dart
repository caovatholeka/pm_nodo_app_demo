import 'dart:async';

class AppEvent {
  AppEvent._();
  static final AppEvent instance = AppEvent._();

  final onTokenExpired = StreamController<bool>.broadcast();
  final onServerBusy = StreamController<bool>.broadcast();

  void dispose() {
    onTokenExpired.close();
    onServerBusy.close();
  }
}