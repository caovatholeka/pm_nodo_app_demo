import 'package:intl/intl.dart';
import '../../config/app_config.dart';

class AppDateUtils {
  static DateTime? fromString(String? date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  static String changeIso8601StringToDateTimeString(String? iso8601String) {
    try {
      DateTime dateTime = DateTime.parse(iso8601String ?? '');
      return DateFormat(AppConfig.dateFormat).format(dateTime.toLocal());
    } catch (e) {
      return "";
    }
  }

  static DateTime convertStringDateToDateTime(String date){
    try{
      return DateTime.parse(date);
    }catch (e) {
      return DateTime.now();
    }
  }
}