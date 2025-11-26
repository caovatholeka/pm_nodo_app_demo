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

  String formatIsoToYyyyMmDd(String input) {
    final dt = DateTime.parse(input);
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static String? parseDateToYMD(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd/MM/yyyy').parseStrict(input.trim()));
    } catch (_) {
      return null;
    }
  }

 static String? parseBirthdayDate(String s) {
    final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(s);
    return DateFormat('yyyy-MM-dd').format(dt);
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

  static List<DateTime> daysBetween(
      DateTime start,
      DateTime end, {
        bool inclusive = true,
        bool useUtc = false,
      }) {
    DateTime normalize(DateTime x) =>
        useUtc ? DateTime.utc(x.year, x.month, x.day) : DateTime(x.year, x.month, x.day);

    var s = normalize(start);
    var e = normalize(end);

    if (s.isAfter(e)) {
      final tmp = s;
      s = e;
      e = tmp;
    }

    final addEnd = inclusive ? 1 : 0;
    final totalDays = e.difference(s).inDays + addEnd;
    if (totalDays <= 0) return <DateTime>[];

    return List.generate(totalDays, (i) => s.add(Duration(days: i)));
  }

  static String getCurrentTimeAM() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a'); // 12h + AM/PM
    return formatter.format(now);
  }
}