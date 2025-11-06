import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger/logger.dart';
import '../models/entities/token_entity.dart';

class SharedPrefsHelper {
  static const String _tokenPrefs = "token";

  static const String _isLoginApp = "_isLoginApp";
  static const String isLoginFirstApp = "isLoginFirstApp";
  static const String _languageSetPrefs = "_language_set_prefs";
  static const String _appLanguagePrefs = '_app_language_prefs';
  static const String _appFcmToken = '_app_fcm_token';
  static const String _appDeviceToken = '_app_device_token';
  static const String _appDeviceId = '_app_device_id';
  static const String _userId = 'app_user_id';

  static Future<bool> setIsLoginApp(bool isCheck) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isLoginApp, isCheck);
  }

  static Future<bool> getIsLoginApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool(_isLoginApp);
    if (value == null) {
      return true;
    }
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
    if (token == null) {
      return null;
    } else {
      try {
        return TokenEntity.fromJson(json.decode(token));
      } catch (e) {
        logger.d(e);
      }
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appFcmToken, fcmToken);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appDeviceId, deviceId);
  }

  static Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString(_appDeviceId) ?? '';
    return code;
  }
}