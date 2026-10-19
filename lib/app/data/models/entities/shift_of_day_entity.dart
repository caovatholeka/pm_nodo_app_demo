/// Ca được phân cho nhân viên trong một ngày (API `/metadata/shift_as_day`).
/// [start]/[end] là giờ địa phương, tính từ `hour_from`/`hour_to` của ca (vd 8.5 → 08:30).
class ShiftOfDayEntity {
  final String? name;
  final DateTime start;
  final DateTime end;

  const ShiftOfDayEntity({this.name, required this.start, required this.end});

  /// Ca nghỉ (CT / L: 0:00–0:00) — không có giờ làm.
  bool get isDayOff => !end.isAfter(start);

  /// Lấy ca của [day] từ `data` của API; không có ca (hoặc dữ liệu lạ) → null.
  static ShiftOfDayEntity? fromApiData(dynamic data, DateTime day) {
    if (data is! List) return null;
    for (final row in data) {
      final shift = row is Map ? row['shift'] : null;
      if (shift is! Map) continue;
      final from = _toDouble(shift['hour_from']);
      final to = _toDouble(shift['hour_to']);
      if (from == null || to == null) continue;
      final base = DateTime(day.year, day.month, day.day);
      final start = base.add(Duration(minutes: (from * 60).round()));
      var end = base.add(Duration(minutes: (to * 60).round()));
      if (to < from) end = end.add(const Duration(days: 1)); // ca qua đêm
      return ShiftOfDayEntity(name: shift['name']?.toString(), start: start, end: end);
    }
    return null;
  }

  static double? _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

  @override
  bool operator ==(Object other) =>
      other is ShiftOfDayEntity &&
      other.name == name &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(name, start, end);
}
