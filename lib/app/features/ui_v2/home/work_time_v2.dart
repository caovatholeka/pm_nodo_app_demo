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
  /// Số giờ làm thực cần đạt trong ngày: theo ca được phân (giờ ca trừ nghỉ trưa),
  /// không có ca thì [WorkRuleV2.requiredWork].
  final Duration required;

  /// Thời gian làm việc thực đã tích luỹ (đã trừ nghỉ trưa).
  final Duration worked;

  /// Thời gian còn lại để đủ [WorkRuleV2.requiredWork]; bằng 0 khi đã đủ.
  final Duration remaining;

  /// Thời điểm sớm nhất đủ giờ để chấm công ra.
  final DateTime earliestOut;

  /// Đã đủ giờ hay chưa.
  bool get done => remaining == Duration.zero;

  const WorkProgressV2({
    required this.required,
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

/// Giờ làm thực giữa [from]..[to] (đã trừ nghỉ trưa).
Duration workBetweenV2(DateTime from, DateTime to) {
  if (!to.isAfter(from)) return Duration.zero;
  return to.difference(from) - lunchOverlapV2(from, to);
}

/// Tính tiến độ giờ công.
///
/// [checkIn] giờ chấm công vào (null -> trả null vì chưa bắt đầu).
/// [checkOut] nếu đã chấm ra thì tính tới thời điểm đó, ngược lại tính tới [now].
/// [shiftStart]/[shiftEnd] ca được phân hôm nay (vd 08:00–17:30): số giờ cần đạt = giờ
/// ca trừ nghỉ trưa, và không bao giờ gợi ý ra trước giờ kết thúc ca (server đánh "về
/// sớm" theo giờ kết thúc ca). Không có ca → quy tắc mặc định 8 tiếng như cũ.
WorkProgressV2? computeWorkProgressV2({
  required DateTime? checkIn,
  required DateTime now,
  DateTime? checkOut,
  DateTime? shiftStart,
  DateTime? shiftEnd,
}) {
  if (checkIn == null) return null;

  final hasShift =
      shiftStart != null && shiftEnd != null && shiftEnd.isAfter(shiftStart);
  final required =
      hasShift ? workBetweenV2(shiftStart, shiftEnd) : WorkRuleV2.requiredWork;

  final until = checkOut ?? now;
  final worked = workBetweenV2(checkIn, until);

  // Thời điểm đủ giờ: cộng phần còn thiếu, đẩy thêm nếu vắt qua nghỉ trưa.
  var target = checkIn.add(required);
  for (var i = 0; i < 2; i++) {
    final overlap = lunchOverlapV2(checkIn, target);
    final adjusted = checkIn.add(required + overlap);
    if (adjusted == target) break;
    target = adjusted;
  }
  if (hasShift && target.isBefore(shiftEnd)) target = shiftEnd;

  // Giờ làm còn lại tới lúc được ra (= required - worked khi không bị giờ kết thúc ca giữ lại)
  final remaining = workBetweenV2(until, target);

  return WorkProgressV2(
    required: required,
    worked: worked,
    remaining: remaining,
    earliestOut: target,
  );
}

/// Giờ vào ca mặc định khi chưa có ca được phân (như thẻ chấm công ở Home: 08:30).
const int defaultShiftStartMinutesV2 = 8 * 60 + 30;

/// Được vào muộn tối đa bao lâu so với giờ bắt đầu ca mà vẫn hiện thanh "đủ giờ".
const Duration lateGraceV2 = Duration(minutes: 15);

/// Có hiện thanh tiến độ + dòng "Còn … nữa đủ giờ" không: chỉ khi chấm công vào đúng giờ
/// (trước hoặc đúng giờ bắt đầu ca được phân) hoặc muộn tối đa [lateGraceV2]. Không có ca
/// → so với [defaultShiftStartMinutesV2]. So theo phút như giờ hiển thị trên thẻ (08:45:59
/// vẫn tính là 08:45).
bool showWorkProgressV2({required DateTime? checkIn, DateTime? shiftStart}) {
  if (checkIn == null) return false;
  final start = shiftStart ??
      DateTime(checkIn.year, checkIn.month, checkIn.day)
          .add(const Duration(minutes: defaultShiftStartMinutesV2));
  final inMinute = DateTime(
      checkIn.year, checkIn.month, checkIn.day, checkIn.hour, checkIn.minute);
  return !inMinute.isAfter(start.add(lateGraceV2));
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
