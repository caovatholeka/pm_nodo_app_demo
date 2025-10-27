import 'dart:async';

class DebouncerHelper {
  Duration delay;
  Timer? _timer;
  Function? _callback;

  DebouncerHelper({this.delay = const Duration(milliseconds: 500)});

  void debounce(Function callback) {
    _callback = callback;

    cancel();
    _timer = Timer(delay, flush);
  }

  void cancel() {
    if (_timer != null) {
      _timer?.cancel();
    }
  }

  void flush() {
    _callback?.call();
    cancel();
  }
}
