import 'package:flutter/foundation.dart';

/// Bật log đo hiệu năng khi build kèm `--dart-define=PERF_LOG=true` (in được cả ở bản
/// profile/release để đo đúng hiệu năng thật). Build bình thường: không in gì.
const bool kPerfLog = bool.fromEnvironment('PERF_LOG');

void perfLog(String message) {
  if (kPerfLog || kDebugMode) {
    debugPrint('[PERF] $message');
  }
}
