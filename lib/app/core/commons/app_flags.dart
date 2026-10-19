import 'package:flutter/foundation.dart';

import 'global_data.dart';

/// Cờ bật tính năng theo tài khoản. TẠM cho giai đoạn thử nghiệm UI mới.
class AppFlags {
  AppFlags._();

  /// Danh sách email được thấy giao diện mới (dark premium).
  static const Set<String> betaUiEmails = {
    'anhpt@nodo.vn',
    'datdt@nodo.vn',
  };

  static bool isBetaUiEmail(String? email) {
    if (email == null) return false;
    return betaUiEmails.contains(email.trim().toLowerCase());
  }

  /// Tài khoản đang đăng nhập có bật UI mới không.
  static bool isBetaUiActive() =>
      kDebugMode || isBetaUiEmail(GlobalData.instance.userProfile?.email);
}
