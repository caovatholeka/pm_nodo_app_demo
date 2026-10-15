import 'package:intl/intl.dart';
import '../../config/app_config.dart';

class AppDateUtils {
  static final List<DateFormat> _flexibleDateFormats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('MM/yyyy'),
    DateFormat('yyyy-MM'),
    DateFormat('yyyy-MM-dd HH:mm:ss'),
  ];

  static DateTime? fromString(String? date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseFlexibleDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();
    final parsed =
        DateTime.tryParse(value) ??
        DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (parsed != null) return parsed;

    for (final format in _flexibleDateFormats) {
      try {
        return format.parseStrict(value);
      } catch (_) {}
    }

    return null;
  }

  static String formatFlexibleDateForDisplay(
    String? raw, {
    String fallback = '',
    String datePattern = 'dd/MM/yyyy',
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;

    final value = raw.trim();
    if (RegExp(r'^\d{2}/\d{4}$').hasMatch(value)) {
      return value;
    }

    final parsed = parseFlexibleDate(value);
    if (parsed == null) return value;

    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(value)) {
      return DateFormat('MM/yyyy').format(parsed);
    }

    return DateFormat(datePattern).format(parsed);
  }

  String formatIsoToYyyyMmDd(String input) {
    final dt = DateTime.parse(input);
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static String? parseDateToYMD(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    try {
      return DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parseStrict(input.trim()));
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

  String formatTimeAmPm(String input) {
    try {
      final dt = _parseLocal(input);

      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      final suffix = dt.hour >= 12 ? 'pm' : 'am';

      return '$hh:$mm $suffix';
    } catch (_) {
      return "";
    }
  }

  /// "2026-10-15 14:20:01" -> "14:20" (giờ 24h, không kèm am/pm).
  String formatTimeHm(String input) {
    try {
      final dt = _parseLocal(input);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return "";
    }
  }

  DateTime _parseLocal(String s) {
    return DateTime.parse(s.replaceFirst(' ', 'T'));
  }

  String formatDateTime(String input) {
    final dt = _parseLocal(input);
    const weekdaysVI = {
      DateTime.monday: 'thứ hai',
      DateTime.tuesday: 'thứ ba',
      DateTime.wednesday: 'thứ tư',
      DateTime.thursday: 'thứ năm',
      DateTime.friday: 'thứ sáu',
      DateTime.saturday: 'thứ bảy',
      DateTime.sunday: 'chủ nhật',
    };
    final wd = weekdaysVI[dt.weekday]!;
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$wd , $d/$m/$y';
  }

  static DateTime convertStringDateToDateTime(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
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
        useUtc
            ? DateTime.utc(x.year, x.month, x.day)
            : DateTime(x.year, x.month, x.day);

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
    try {
      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a'); // 12h + AM/PM
      return formatter.format(now);
    } catch (e) {
      return "";
    }
  }
}
