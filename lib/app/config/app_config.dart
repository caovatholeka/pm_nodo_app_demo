import 'app_env.dart';

class AppConfig {

  static const appName = "Nodo PM App";
  static Environment env = Environment.dev;

  ///API Env
  static  get baseUrl => env.baseUrl;
  static String get envName => env.envName;
  static const baseImgUrl = "";

  static const baseFaceIdUrl = "https://pm.nodo.vn/";

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