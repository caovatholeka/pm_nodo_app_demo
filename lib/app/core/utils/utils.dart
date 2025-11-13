import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';

class Utils {
  static String dateTimeToString(DateTime? dateTime,
      {String pattern = AppConfig.dateTimeFormat}) {
    if (dateTime == null) {
      return '';
    }
    try {
      return DateFormat(pattern).format(dateTime.toLocal());
    } catch (e) {
      return '';
    }
  }

  static double? dynamicToDouble(dynamic value) {
    return double.tryParse('$value');
  }

  static int? dynamicToInt(dynamic value) {
    return int.tryParse('$value');
  }

  // tính khoảng cách được checkin
  double calcDistanceMetersGeolocator(
      double schoolLat, double schoolLon, double userLat, double userLon,
      ) {
    return Geolocator.distanceBetween(schoolLat, schoolLon, userLat, userLon); // mét
  }

  bool isNowInWindowToday(String fromTime, String toTime,
      {int preMinutes = 20, DateTime? now}) {
    now ??= DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);

    return _isNowInWindow(dateStr, fromTime, toTime,
        preMinutes: preMinutes, now: now);
  }

  // validate thời gian được phép check-in
  bool _isNowInWindow(String dmy, String fromTime, String toTime,
      {required int preMinutes, required DateTime now}) {
    final dtFmt = DateFormat('dd/MM/yyyy HH:mm');
    DateTime? start, end;
    try {
      start = dtFmt.parseStrict('$dmy $fromTime'); // from
      end = dtFmt.parseStrict('$dmy $toTime');     // to
    } catch (_) {
      return false;
    }

    // nếu ca qua đêm (toTime < fromTime) thì có thể cộng 1 ngày cho end
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final preStart = start.subtract(Duration(minutes: preMinutes));

    final inPreWindow =
        !now.isBefore(preStart) && now.isBefore(start);
    final inDuring =
        !now.isBefore(start) && now.isBefore(end);

    return inPreWindow || inDuring;
  }


  bool isTodayBetween({
    required String startStr,
    required String endStr,
    String pattern = 'dd/MM/yyyy',
    bool inclusive = true,
  }) {
    DateTime parseDate(String s) =>
        DateFormat(pattern).parseStrict(s);

    // parse
    var start = parseDate(startStr);
    var end   = parseDate(endStr);

    if (start.isAfter(end)) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    DateTime toDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    final today = toDateOnly(DateTime.now());
    start = toDateOnly(start);
    end   = toDateOnly(end);

    if (inclusive) {
      return (today.isAtSameMomentAs(start) || today.isAfter(start)) &&
          (today.isAtSameMomentAs(end)   || today.isBefore(end));
    } else {
      return today.isAfter(start) && today.isBefore(end);
    }
  }

  bool _looksLikeBitmap(Uint8List b) {
    // PNG
    if (b.length >= 8 &&
        b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      return true;
    }
    // JPEG
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8) return true;
    // WEBP
    if (b.length >= 12 &&
        b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 && // "RIFF"
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return true;
    }
    // GIF
    if (b.length >= 6 &&
        b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38) {
      return true;
    }
    return false;
  }

  Uint8List? decodeBase64(String b64) {
    // var cleaned = b64.trim();
    // if (cleaned.contains(',')) {
    //   cleaned = cleaned.split(',').last;
    // }
    // cleaned = cleaned.replaceAll(RegExp(r'\s'), '');
    // final pad = cleaned.length % 4;
    // if (pad > 0) cleaned += '=' * (4 - pad);
    // return base64Decode(cleaned);

    try {
      final noHeader = b64.split(',').last;
      final compact = noHeader.replaceAll(RegExp(r'\s'), '');
      final normalized = base64.normalize(compact);
      Uint8List bytes;
      try {
        bytes = base64.decode(normalized);
      } catch (_) {
        bytes = base64Url.decode(normalized);
      }

      if (_looksLikeBitmap(bytes)) return bytes;

      return null;
    } catch (_) {
      return null;
    }
  }

  ImageProvider providerFromBase64OrAsset(
      String base64String, {
        required String fallbackAssetPath,
      }) {
    final bytes = decodeBase64(base64String);
    if (bytes == null) {
      return AssetImage(fallbackAssetPath);
    }
    return MemoryImage(bytes);
  }

  String toHhMm(String s) {
    if (s.isEmpty) return "00:00";
    try {
      final dt = DateFormat('HH:mm:ss').parseStrict(s);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return s.length >= 5 ? s.substring(0, 5) : s;
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      throw 'Could not call $phone';
    }
  }

  Future<void> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (!await launchUrl(uri)) {
      throw 'Could not email $to';
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // fallback mở Google Maps web
      final web = Uri.parse('https://maps.google.com/?q=$lat,$lng');
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }
}