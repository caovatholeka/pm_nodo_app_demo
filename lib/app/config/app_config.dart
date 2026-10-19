import '../data/local/shared_prefs_helper.dart';
import 'app_env.dart';


class AppConfig {

  static const appName = "Nodo PM App";
  static Environment env = Environment.dev;

  ///API Env
  static String? nameEnv = '';
  static String? version = '1.1.6';
  static String baseUrl = "https://pm.nodo.vn/";//env.baseUrl;
  static String get envName => env.envName;
  static const baseImgUrl = "";

  /// Environments
  static const devEnviroment = "https://api-nodo-pm-dev.com/";
  static const stagingEnviroment = "https://api-nodo-pm-staging.vn/";
  static const prodEnviroment = "https://api.nodo-pm.vn/";

  /// Local dev server, e.g. `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8075/`
  /// Empty in normal builds, so the environment switch below applies unchanged.
  static const localBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Local face service (dev mock), e.g. `--dart-define=FACE_BASE_URL=http://192.168.1.55:8076/`
  static const localFaceBaseUrl = String.fromEnvironment('FACE_BASE_URL');

  static String get baseFaceIdUrl => localFaceBaseUrl.isNotEmpty
      ? localFaceBaseUrl
      : (localBaseUrl.isNotEmpty ? localBaseUrl : "https://pm.nodo.vn/");

  static void setEnvironment(Environment environment) {
    env = environment;

    if (localBaseUrl.isNotEmpty) {
      baseUrl = localBaseUrl;
      nameEnv = 'Môi trường: Local ($localBaseUrl)';
      return;
    }

    switch (environment) {
      case Environment.dev:
        baseUrl = 'https://pm.nodo.vn/';
        nameEnv = 'Môi trường: develop';
        SharedPrefsHelper.setAppEnv(Environment.dev);
        break;
      case Environment.demo:
        baseUrl = 'https://demo-hrm.nodo.vn/';
        nameEnv = 'Môi trường: Demo';
        SharedPrefsHelper.setAppEnv(Environment.demo);
        break;
      case Environment.test:
        baseUrl = 'https://test-pm.nodo.vn/';
        nameEnv = 'Môi trường: Test';
        SharedPrefsHelper.setAppEnv(Environment.test);
        break;
      case Environment.prod:
        baseUrl = 'https://pm.nodo.vn/';
        nameEnv = 'Môi trường: Prod';
        SharedPrefsHelper.setAppEnv(Environment.prod);
        break;
    }
  }

  ///Paging
  static const pageSize = 20;
  static const pageSizeMax = 1000;

  static const appLocal = 'vi_VN';
  static const dateFormat = 'dd/MM/yyyy';
  static const birthdayFormat = 'dd-MM-yyyy';
  static const birthdayReservedFormat = 'yyyy-MM-dd';
  static const dateReservedFormat = 'yyyy/MM/dd';
  static const dateTimeFormat = 'dd/MM/yyyy, HH:mm:ss';
  static const dateTimeFormatHd = 'HH:mm, dd/MM/yyyy';
  static const iso8601Format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const iso8601FormatSpl = 'yyyy-MM-ddTHH:mm:ss';
  static const dateReservedTimeFormat = 'HH:mm:ss, dd/MM/yyyy';
  static const dateFormatNonSecond = 'dd/MM/yyyy, HH:mm';

  static const timeFormatNonSecond = 'HH:mm';

  /// Font
  static const fontFamily = 'Roboto';
  static const fontInter = 'Inter';

  // Tracker
  static String get logId => env.logId;
}