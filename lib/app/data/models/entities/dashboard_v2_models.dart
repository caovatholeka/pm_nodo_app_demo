/// Dữ liệu màn Dashboard v2 — đồng bộ với Dashboard web (các API /dashboard/* gọi chính
/// hàm của web nên số liệu giống hệt). Đọc thủ công, chịu được thiếu trường/sai kiểu: một
/// thẻ lỗi dữ liệu không làm hỏng cả màn.
library;

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _str(dynamic v) => v == null || v == false ? '' : v.toString();

List<Map<String, dynamic>> _maps(dynamic v) {
  if (v is! List) return const [];
  return v
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList(growable: false);
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const {};

/// Một ô đếm (Nghỉ phép, Xin OT, Tổng NV, ...).
class DashboardCount {
  final String key;
  final String label;
  final int count;

  const DashboardCount({required this.key, required this.label, required this.count});

  factory DashboardCount.fromJson(Map<String, dynamic> json) => DashboardCount(
        key: _str(json['key']),
        label: _str(json['label']),
        count: _int(json['count']),
      );
}

/// Thẻ gồm nhiều ô đếm: "Đơn từ cá nhân trong tháng", "Đơn cần duyệt...", "Tổng quan nhân sự".
class DashboardCountCard {
  final String title;
  final List<DashboardCount> items;

  /// Chỉ có ở "Đơn cần duyệt": người xem có nhân viên cấp dưới hay không.
  final bool hasSubordinates;
  final int total;

  const DashboardCountCard({
    this.title = '',
    this.items = const [],
    this.hasSubordinates = false,
    this.total = 0,
  });

  factory DashboardCountCard.fromJson(dynamic data) {
    final json = _map(data);
    final items = _maps(json['items']).map(DashboardCount.fromJson).toList();
    return DashboardCountCard(
      title: _str(json['title']),
      items: items,
      hasSubordinates: json['has_subordinates'] == true,
      total: json.containsKey('total')
          ? _int(json['total'])
          : items.fold(0, (sum, e) => sum + e.count),
    );
  }
}

/// Một chỉ số "Nề nếp chấm công" (Muộn/Sớm, Quên chấm công, Thiếu vào/ra).
class BehaviourItem {
  final String key;
  final String label;
  final String chartLabel;
  final int count;

  /// Màu như web, dạng "#E24B4A".
  final String color;

  const BehaviourItem({
    required this.key,
    required this.label,
    required this.chartLabel,
    required this.count,
    required this.color,
  });

  factory BehaviourItem.fromJson(Map<String, dynamic> json) => BehaviourItem(
        key: _str(json['key']),
        label: _str(json['label']),
        chartLabel: _str(json['chart_label']).isEmpty
            ? _str(json['label'])
            : _str(json['chart_label']),
        count: _int(json['count']),
        color: _str(json['color']),
      );
}

class DashboardBehaviour {
  final String title;
  final List<BehaviourItem> items;

  const DashboardBehaviour({this.title = '', this.items = const []});

  factory DashboardBehaviour.fromJson(dynamic data) {
    final json = _map(data);
    return DashboardBehaviour(
      title: _str(json['title']),
      items: _maps(json['items']).map(BehaviourItem.fromJson).toList(),
    );
  }
}

/// Một dòng "Cảnh báo chuyên cần trong tháng".
class AttendanceAlert {
  final String key;

  /// danger | warning | info | success
  final String level;
  final String dotColor;
  final String title;
  final String description;

  const AttendanceAlert({
    required this.key,
    required this.level,
    required this.dotColor,
    required this.title,
    required this.description,
  });

  factory AttendanceAlert.fromJson(Map<String, dynamic> json) => AttendanceAlert(
        key: _str(json['key']),
        level: _str(json['level']),
        dotColor: _str(json['dot_color']),
        title: _str(json['title']),
        description: _str(json['description']),
      );
}

class DashboardAlerts {
  final String title;
  final List<AttendanceAlert> items;

  const DashboardAlerts({this.title = '', this.items = const []});

  factory DashboardAlerts.fromJson(dynamic data) {
    final json = _map(data);
    return DashboardAlerts(
      title: _str(json['title']),
      items: _maps(json['items']).map(AttendanceAlert.fromJson).toList(),
    );
  }
}

/// Một người trong "Sinh nhật trong tháng".
class BirthdayPerson {
  final int employeeId;
  final String name;

  /// URL ảnh (S3) hoặc rỗng.
  final String avatar;

  /// "dd/MM" — web chủ ý không hiện năm sinh.
  final String dob;
  final String dept;
  final bool wished;

  const BirthdayPerson({
    required this.employeeId,
    required this.name,
    required this.avatar,
    required this.dob,
    required this.dept,
    required this.wished,
  });

  factory BirthdayPerson.fromJson(Map<String, dynamic> json) => BirthdayPerson(
        employeeId: _int(json['employee_id']),
        name: _str(json['name']),
        avatar: _str(json['avatar']),
        dob: _str(json['dob']),
        dept: _str(json['dept']),
        wished: json['wished'] == true,
      );
}

class DashboardBirthdays {
  final String title;
  final List<BirthdayPerson> items;

  const DashboardBirthdays({this.title = '', this.items = const []});

  factory DashboardBirthdays.fromJson(dynamic data) {
    final json = _map(data);
    return DashboardBirthdays(
      title: _str(json['title']),
      items: _maps(json['birthdays']).map(BirthdayPerson.fromJson).toList(),
    );
  }
}
