import 'global_data.dart';

/// Cờ bật tính năng theo tài khoản. TẠM cho giai đoạn thử nghiệm UI mới.
class AppFlags {
  AppFlags._();

  /// Danh sách email được thấy giao diện mới (dark premium).
  static const Set<String> betaUiEmails = {
    'anhpt@nodo.vn',
  };

  static bool isBetaUiEmail(String? email) {
    if (email == null) return false;
    return betaUiEmails.contains(email.trim().toLowerCase());
  }

  /// Email của tài khoản đăng nhập gần nhất, đọc từ SharedPreferences lúc khởi
  /// động app (xem `main.dart`). Cần vì ở màn splash/login, profile chưa được
  /// tải từ server nên [GlobalData.userProfile] còn null.
  static String? cachedLoginEmail;

  /// Email dùng để quyết định giao diện: ưu tiên profile đang có (chính xác
  /// nhất), nếu chưa có thì dùng email đã lưu lúc đăng nhập lần trước.
  static String? get currentEmail {
    final live = GlobalData.instance.userProfile?.email;
    if (live != null && live.trim().isNotEmpty) return live;
    return cachedLoginEmail;
  }

  /// Tài khoản hiện tại có bật UI mới không. Dùng được cả trước khi đăng nhập
  /// (dựa trên email đã lưu) lẫn sau khi đã có profile.
  static bool isBetaUiActive() => isBetaUiEmail(currentEmail);
}
