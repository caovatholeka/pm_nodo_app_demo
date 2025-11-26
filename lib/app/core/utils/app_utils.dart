import 'package:intl/intl.dart';

class AppUtil {
  // String? parseDateToYMD(String? input) {
  //   if (input == null || input.trim().isEmpty) return null;
  //   try {
  //     return DateFormat('yyyy-MM-dd')
  //         .format(DateFormat('dd/MM/yyyy').parseStrict(input.trim()));
  //   } catch (_) {
  //     return null;
  //   }
  // }

  String? extractTime(String? input) {
    if(input == null){
      return "";
    }
    final match = RegExp(r'\b(?:[01]?\d|2[0-3]):[0-5]\d\b').firstMatch(input);
    return match?.group(0);
  }
}