import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_env.dart';
import '../../core/logger/logger.dart';
import '../models/entities/token_entity.dart';

class SharedPrefsHelper {
  static const String _tokenPrefs = "token";

  static const String _isLoginApp = "_isLoginApp";
  static const String isLoginFirstApp = "isLoginFirstApp";
  static const String _appLanguagePrefs = '_app_language_prefs';
  static const String _appFcmToken = '_app_fcm_token';
  static const String _appDeviceToken = '_app_device_token';
  static const String _appDeviceType = '_app_device_type';
  static const String _appDeviceId = '_app_device_id';
  static const String _userId = 'app_user_id';
  static const String _checkIn = 'check_in_out';
  static const String _loginUsername = 'login_username';
  static const String _env = 'app_env';

  /// Tài khoản đăng nhập gần nhất. Khác [_loginUsername] ("nhớ tài khoản", chỉ
  /// lưu khi user bật) — key này LUÔN lưu khi đăng nhập thành công, để lúc khởi
  /// động app (chưa có profile từ server) vẫn biết nên hiện giao diện nào.
  static const String _lastLoginEmail = 'last_login_email';

  static Future<bool> setIsLoginApp(bool isCheck) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isLoginApp, isCheck);
  }

  static Future<bool> getIsLoginApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_isLoginApp) ?? false;
    return value;
  }

static Future<void> saveToken(TokenEntity? token) async {
  final prefs = await SharedPreferences.getInstance();
  if (token == null ||
      (token.accessToken == null || token.accessToken!.isEmpty)) {
    await prefs.remove(_tokenPrefs);
    await prefs.reload();
  } else {
    await prefs.setString(_tokenPrefs, json.encode(token.toJson()));
    await prefs.reload();
  }
}

    static Future<void> clearAll() async {
       final prefs = await SharedPreferences.getInstance();
       await prefs.clear();
    }



  static Future<TokenEntity?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenPrefs);
    try {
      if (token != null) {
        return TokenEntity.fromJson(json.decode(token));
      }
    } catch (e) {
      logger.d(e);
    }
      return null;
  }
  

  // app language
  static Future<void> setAppLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appLanguagePrefs, language);
  }

  static Future<String> getAppLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString(_appLanguagePrefs) ?? 'vi';
    return code;
  }

  static Future<void> setUserId(int uId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userId, uId);
  }

  static Future<int> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int uId = prefs.getInt(_userId) ?? 0;
    return uId;
  }


  static Future<void> setFcmToken(String fcmToken) async {
    final normalized = fcmToken.trim();
    if (normalized.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appFcmToken, normalized);
  }

  static Future<String> getFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString(_appFcmToken) ?? '';
    return code;
  }

  static Future<void> setDeviceToken(String deviceToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDeviceToken, deviceToken);
  }

  static Future<String> getDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString(_appDeviceToken) ?? '';
    return code;
  }

  static Future<void> setDeviceId(String deviceId) async {
    final normalized = deviceId.trim();
    if (normalized.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDeviceId, normalized);
  }

  static Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString(_appDeviceId) ?? '';
    return code;
  }

  static Future<void> setDeviceType(String type) async {
    final normalized = type.trim();
    if (normalized.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDeviceType, normalized);
  }

  static Future<String> getDeviceType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String type = prefs.getString(_appDeviceType) ?? '';
    return type;
  }

  // lưu trạng thái check-in out
  static Future<void> setCheckInOutAction(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkIn, action);
  }

  static Future<String> getCheckInOutAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String action = prefs.getString(_checkIn) ?? '';
    return action;
  }


  // moi truong
  static Future<void> setAppEnv(Environment appEnv) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_env, appEnv.envName);
  }

  static Future<Environment> getAppEnv() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String env = prefs.getString(_env) ?? 'PROD';
    return EnvironmentExt.fromName(env);
  }

  //Nhớ tài khoản 
  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginUsername, username);
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginUsername) ?? "";
  }

  /// Tài khoản đăng nhập gần nhất (luôn lưu, không phụ thuộc "nhớ tài khoản").
  static Future<void> setLastLoginEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginEmail, email.trim().toLowerCase());
  }

  static Future<String> getLastLoginEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLoginEmail) ?? "";
  }
}
