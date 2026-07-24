/// Tính tiến độ giờ công trong ngày (logic thuần, không phụ thuộc Flutter).
///
/// Quy tắc công ty: đủ **8 tiếng làm việc thực**; nghỉ trưa **1h30** không được
/// tính vào giờ làm. Ví dụ: vào 08:30 → đủ giờ lúc 18:00.
library;

class WorkRuleV2 {
  WorkRuleV2._();

  /// Số giờ làm việc thực cần đạt trong ngày.
  static const Duration requiredWork = Duration(hours: 8);

  /// Khung nghỉ trưa (không tính vào giờ làm): 12:00 -> 13:30.
  static const int lunchStartMinutes = 12 * 60; // 12:00
  static const int lunchEndMinutes = 13 * 60 + 30; // 13:30

  static Duration get lunchDuration =>
      Duration(minutes: lunchEndMinutes - lunchStartMinutes);
}

class WorkProgressV2 {
  /// Thời gian làm việc thực đã tích luỹ (đã trừ nghỉ trưa).
  final Duration worked;

  /// Thời gian còn lại để đủ [WorkRuleV2.requiredWork]; bằng 0 khi đã đủ.
  final Duration remaining;

  /// Thời điểm sớm nhất đủ giờ để chấm công ra.
  final DateTime earliestOut;

  /// Đã đủ giờ hay chưa.
  bool get done => remaining == Duration.zero;

  const WorkProgressV2({
    required this.worked,
    required this.remaining,
    required this.earliestOut,
  });
}

/// Phần giao (phút) giữa [from]..[to] và khung nghỉ trưa trong cùng ngày của [from].
Duration lunchOverlapV2(DateTime from, DateTime to) {
  if (!to.isAfter(from)) return Duration.zero;
  final day = DateTime(from.year, from.month, from.day);
  final lunchStart = day.add(Duration(minutes: WorkRuleV2.lunchStartMinutes));
  final lunchEnd = day.add(Duration(minutes: WorkRuleV2.lunchEndMinutes));

  final start = from.isAfter(lunchStart) ? from : lunchStart;
  final end = to.isBefore(lunchEnd) ? to : lunchEnd;
  if (!end.isAfter(start)) return Duration.zero;
  return end.difference(start);
}

/// Tính tiến độ giờ công.
///
/// [checkIn] giờ chấm công vào (null -> trả null vì chưa bắt đầu).
/// [checkOut] nếu đã chấm ra thì tính tới thời điểm đó, ngược lại tính tới [now].
WorkProgressV2? computeWorkProgressV2({
  required DateTime? checkIn,
  required DateTime now,
  DateTime? checkOut,
}) {
  if (checkIn == null) return null;

  final until = checkOut ?? now;
  final rawElapsed =
      until.isAfter(checkIn) ? until.difference(checkIn) : Duration.zero;
  var worked = rawElapsed - lunchOverlapV2(checkIn, until);
  if (worked < Duration.zero) worked = Duration.zero;

  var remaining = WorkRuleV2.requiredWork - worked;
  if (remaining < Duration.zero) remaining = Duration.zero;

  // Thời điểm đủ giờ: cộng phần còn thiếu, đẩy thêm nếu vắt qua nghỉ trưa.
  var target = checkIn.add(WorkRuleV2.requiredWork);
  for (var i = 0; i < 2; i++) {
    final overlap = lunchOverlapV2(checkIn, target);
    final adjusted = checkIn.add(WorkRuleV2.requiredWork + overlap);
    if (adjusted == target) break;
    target = adjusted;
  }

  return WorkProgressV2(
    worked: worked,
    remaining: remaining,
    earliestOut: target,
  );
}

/// Thời điểm nên bắn thông báo nhắc chấm công ra; `null` nghĩa là không nhắc.
///
/// Không nhắc khi: chưa chấm vào, đã chấm ra, hoặc thời điểm đủ giờ đã trôi qua
/// (lúc đó màn hình đã hiển thị "đã đủ giờ" rồi).
DateTime? checkOutReminderAtV2({
  required DateTime? checkIn,
  required DateTime? checkOut,
  required DateTime now,
}) {
  if (checkIn == null) return null;
  if (checkOut != null) return null;

  final p = computeWorkProgressV2(checkIn: checkIn, now: now);
  if (p == null) return null;
  if (!p.earliestOut.isAfter(now)) return null;
  return p.earliestOut;
}

/// "2h15p" / "45p" / "0p"
String formatDurationShortV2(Duration d) {
  final total = d.inMinutes;
  final h = total ~/ 60;
  final m = total % 60;
  if (h > 0) return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}p' : '${h}h';
  return '${m}p';
}
