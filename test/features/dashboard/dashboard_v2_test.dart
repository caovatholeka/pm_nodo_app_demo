import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/dashboard_v2_models.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/dashboard_repository.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/cubit/dashboard_v2_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/dashboard_page_v2.dart';
import 'package:pm_app/generated/l10n.dart';

Widget _app(Locale locale) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: locale,
      home: const DashboardPageV2(),
    );

Future<void> _pumpDashboard(WidgetTester tester, Locale locale) async {
  await GetIt.instance.reset();
  // Không có ảnh (test không gọi mạng); 7 cảnh báo để có "Xem tất cả".
  GetIt.instance.registerSingleton<DashboardRepository>(_NoAvatarRepo());
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_app(locale));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

// JSON đúng như API /dashboard/* trả (lấy từ Odoo local, 2026-10-21).
final _requests = {
  'month': '2026-08',
  'title': 'Đơn từ cá nhân trong tháng',
  'items': [
    {'key': 'leave', 'web_key': 'nghi_phep', 'label': 'Nghỉ phép', 'count': 2},
    {'key': 'overtime', 'web_key': 'xin_ot', 'label': 'Xin OT', 'count': 0},
    {'key': 'late_early', 'web_key': 'muon_som', 'label': 'Muộn/Sớm', 'count': 1},
    {'key': 'business_trip', 'web_key': 'cong_tac', 'label': 'Công tác', 'count': 0},
    {'key': 'wfh', 'web_key': 'wfh', 'label': 'WFH', 'count': 0},
  ],
};
final _pending = {
  'month': '2026-08',
  'title': 'Đơn cần duyệt cho nhân sự trong tháng',
  'has_subordinates': true,
  'total': 3,
  'items': [
    {'key': 'leave', 'label': 'Nghỉ phép', 'count': 3},
  ],
};
final _behaviour = {
  'month': '2026-08',
  'on_time_percent': 100,
  'absent_count': 0.0,
  'late_early_count': 0,
  'title': 'Nề nếp chấm công',
  'items': [
    {'key': 'muon_som', 'label': 'Muộn/Sớm', 'chart_label': 'Đi muộn/về sớm', 'count': 4, 'color': '#E24B4A'},
    {'key': 'quen_cham_cong', 'label': 'Quên chấm công', 'chart_label': 'Quên chấm công', 'count': 1, 'color': '#0F6E56'},
    {'key': 'thieu_gio', 'label': 'Thiếu vào/ra', 'chart_label': 'Thiếu vào/ra', 'count': 0, 'color': '#BA7517'},
  ],
};
final _headcount = {
  'title': 'Tổng quan nhân sự',
  'items': [
    {'key': 'total', 'label': 'Tổng NV', 'count': 117},
    {'key': 'official', 'label': 'Chính thức', 'count': 87},
  ],
};
final _birthdays = {
  'month': '08',
  'title': 'Sinh nhật trong tháng',
  'birthdays': [
    {
      'employee_id': 34,
      'name': 'Đào Minh Tâm',
      'avatar': 'https://s3.example/image_128_x',
      'birth_date': '2026-08-01',
      'dob': '01/08',
      'dept': 'Phòng Sản xuất',
      'code': '23',
      'wished': false,
    },
    {'employee_id': 35, 'name': 'Không Ảnh', 'avatar': null, 'dob': '04/08', 'dept': false},
  ],
};
final _alerts = {
  'month': '2026-08',
  'title': 'Cảnh báo chuyên cần trong tháng',
  'total': 1,
  'items': [
    {
      'type': 'missing_attendance',
      'key': 'quen_cham_cong',
      'level': 'danger',
      'dot_color': '#E24B4A',
      'title': 'Quên chấm công — Bùi Thị Thơm',
      'description': '15 lần trong tháng 8/2026',
      'count': 15,
    },
  ],
};

class _Repo extends Fake implements DashboardRepository {
  final calls = <String>[];
  bool failAlerts = false;

  @override
  Future<dynamic> getDashboardRequests(int month, int year) async {
    calls.add('requests $month/$year');
    return _requests;
  }

  @override
  Future<dynamic> getDashboardPending(int month, int year) async => _pending;

  @override
  Future<dynamic> getDashboardBehaviour(int month, int year) async => _behaviour;

  @override
  Future<dynamic> getDashboardHeadcount() async => _headcount;

  @override
  Future<dynamic> getDashboardBirthdays(int month, int year) async => _birthdays;

  @override
  Future<dynamic> getDashboardAlerts(int month, int year) async {
    if (failAlerts) throw Exception('500');
    return _alerts;
  }
}

void main() {
  group('Đọc dữ liệu', () {
    test('Đơn từ: 5 ô theo nhãn web, có Công tác (không còn Onsite)', () {
      final card = DashboardCountCard.fromJson(_requests);
      expect(card.title, 'Đơn từ cá nhân trong tháng');
      expect(card.items.map((e) => e.label),
          ['Nghỉ phép', 'Xin OT', 'Muộn/Sớm', 'Công tác', 'WFH']);
      expect(card.items.first.count, 2);
    });

    test('Đơn cần duyệt: has_subordinates + total', () {
      final card = DashboardCountCard.fromJson(_pending);
      expect(card.hasSubordinates, isTrue);
      expect(card.total, 3);
    });

    test('Nề nếp: 3 chỉ số như web', () {
      final b = DashboardBehaviour.fromJson(_behaviour);
      expect(b.items.map((e) => e.label), ['Muộn/Sớm', 'Quên chấm công', 'Thiếu vào/ra']);
      expect(b.items.first.chartLabel, 'Đi muộn/về sớm');
      expect(b.items.first.count, 4);
    });

    test('Sinh nhật: dd/MM, phòng ban; trường thiếu/false không làm lỗi', () {
      final d = DashboardBirthdays.fromJson(_birthdays);
      expect(d.items.length, 2);
      expect(d.items.first.dob, '01/08');
      expect(d.items.first.dept, 'Phòng Sản xuất');
      expect(d.items.last.avatar, '');
      expect(d.items.last.dept, '');
    });

    test('Cảnh báo: tiêu đề, mô tả, màu', () {
      final a = DashboardAlerts.fromJson(_alerts);
      expect(a.items.single.title, 'Quên chấm công — Bùi Thị Thơm');
      expect(a.items.single.dotColor, '#E24B4A');
    });

    test('Dữ liệu rác (null / sai kiểu) → thẻ rỗng, không văng lỗi', () {
      expect(DashboardCountCard.fromJson(null).items, isEmpty);
      expect(DashboardBehaviour.fromJson('x').items, isEmpty);
      expect(DashboardAlerts.fromJson({'items': 'x'}).items, isEmpty);
      expect(DashboardBirthdays.fromJson({'birthdays': [1, null]}).items, isEmpty);
    });
  });

  group('Cubit', () {
    test('tải đủ 6 thẻ theo tháng/năm hiện tại', () async {
      final repo = _Repo();
      final cubit = DashboardV2Cubit(repo, now: DateTime(2026, 8, 15));
      await cubit.loadAll();

      final s = cubit.state;
      expect(repo.calls, ['requests 8/2026']);
      expect(s.requestsStatus, LoadStatus.SUCCESS);
      expect(s.pending?.hasSubordinates, isTrue);
      expect(s.behaviour?.items.length, 3);
      expect(s.headcount?.items.first.count, 117);
      expect(s.birthdays?.items.length, 2);
      expect(s.alerts?.items.length, 1);
    });

    test('1 thẻ lỗi không ảnh hưởng thẻ khác', () async {
      final repo = _Repo()..failAlerts = true;
      final cubit = DashboardV2Cubit(repo, now: DateTime(2026, 8, 15));
      await cubit.loadAll();

      expect(cubit.state.alertsStatus, LoadStatus.FAILURE);
      expect(cubit.state.requestsStatus, LoadStatus.SUCCESS);
      expect(cubit.state.birthdaysStatus, LoadStatus.SUCCESS);
    });

    test('đổi tháng → tải lại với tháng mới', () async {
      final repo = _Repo();
      final cubit = DashboardV2Cubit(repo, now: DateTime(2026, 8, 15));
      await cubit.loadAll();
      await cubit.changeMonth(3);

      expect(cubit.state.month, 3);
      expect(repo.calls, ['requests 8/2026', 'requests 3/2026']);
    });
  });

  testWidgets('Màn Dashboard dựng đủ các thẻ ở cỡ điện thoại, không lỗi layout',
      (tester) async {
    await _pumpDashboard(tester, const Locale('vi'));

    expect(find.text('Đơn từ cá nhân trong tháng'), findsOneWidget);
    expect(find.text('Công tác'), findsWidgets);
    expect(find.text('Đơn cần duyệt cho nhân sự trong tháng'), findsOneWidget);
    expect(find.text('Đi muộn/về sớm'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Cảnh báo chuyên cần trong tháng'), 300);
    expect(find.text('Xem tất cả (7)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tiếng Anh: tiêu đề và nhãn ô theo app (không lấy chữ tiếng Việt của server)',
      (tester) async {
    await _pumpDashboard(tester, const Locale('en'));

    expect(find.text('My Requests This Month'), findsOneWidget);
    expect(find.text('Business Trip'), findsWidgets);
    expect(find.text('Late Arrival/Early Leave'), findsOneWidget);
    expect(find.text('Đơn từ cá nhân trong tháng'), findsNothing);
    expect(find.text('Công tác'), findsNothing);

    await tester.scrollUntilVisible(find.text('Attendance Alerts This Month'), 300);
    expect(find.text('See All (7)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _NoAvatarRepo extends _Repo {
  @override
  Future<dynamic> getDashboardBirthdays(int month, int year) async => {
        'title': 'Sinh nhật trong tháng',
        'birthdays': [
          {'employee_id': 35, 'name': 'Không Ảnh', 'avatar': null, 'dob': '04/08', 'dept': 'Phòng A'},
        ],
      };

  @override
  Future<dynamic> getDashboardAlerts(int month, int year) async => {
        'title': 'Cảnh báo chuyên cần trong tháng',
        'items': [
          for (var i = 0; i < 7; i++)
            {'key': 'muon_som', 'level': 'warning', 'dot_color': '#EF9F27',
             'title': 'Đi muộn/về sớm — NV $i', 'description': '$i lần trong tháng 8/2026'},
        ],
      };
}
