import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/features/ui_v2/home/work_time_v2.dart';

DateTime _t(int h, int m) => DateTime(2026, 7, 24, h, m);

void main() {
  group('computeWorkProgressV2', () {
    test('vào 08:30 -> đủ giờ lúc 18:00 (8h làm + 1h30 nghỉ trưa)', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(9, 0));
      expect(p, isNotNull);
      expect(p!.earliestOut, _t(18, 0));
    });

    test('chưa chấm vào -> null', () {
      expect(computeWorkProgressV2(checkIn: null, now: _t(10, 0)), isNull);
    });

    test('lúc 11:00 (vào 08:30): làm 2h30, còn 5h30, chưa đủ', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(11, 0))!;
      expect(p.worked, const Duration(hours: 2, minutes: 30));
      expect(p.remaining, const Duration(hours: 5, minutes: 30));
      expect(p.done, isFalse);
    });

    test('lúc 14:00 (vào 08:30): trừ trọn 1h30 nghỉ trưa -> làm 4h', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(14, 0))!;
      expect(p.worked, const Duration(hours: 4));
      expect(p.remaining, const Duration(hours: 4));
    });

    test('lúc 12:45 (giữa trưa): chỉ tính tới 12:00 -> làm 3h30', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(12, 45))!;
      expect(p.worked, const Duration(hours: 3, minutes: 30));
    });

    test('lúc 18:00 -> đủ giờ, remaining = 0, done', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(18, 0))!;
      expect(p.worked, const Duration(hours: 8));
      expect(p.remaining, Duration.zero);
      expect(p.done, isTrue);
    });

    test('làm quá giờ -> remaining kẹp ở 0, không âm', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(20, 0))!;
      expect(p.remaining, Duration.zero);
      expect(p.done, isTrue);
    });

    test('vào 14:00 (sau nghỉ trưa) -> đủ giờ lúc 22:00, không trừ trưa', () {
      final p = computeWorkProgressV2(checkIn: _t(14, 0), now: _t(15, 0))!;
      expect(p.earliestOut, _t(22, 0));
      expect(p.worked, const Duration(hours: 1));
    });

    test('đã chấm ra thì tính tới giờ ra, không tính tới now', () {
      final p = computeWorkProgressV2(
        checkIn: _t(8, 30),
        checkOut: _t(17, 0),
        now: _t(21, 0),
      )!;
      expect(p.worked, const Duration(hours: 7));
      expect(p.remaining, const Duration(hours: 1));
    });
  });

  group('formatDurationShortV2', () {
    test('định dạng gọn', () {
      expect(formatDurationShortV2(const Duration(hours: 2, minutes: 15)),
          '2h15p');
      expect(formatDurationShortV2(const Duration(minutes: 45)), '45p');
      expect(formatDurationShortV2(const Duration(hours: 3)), '3h');
      expect(formatDurationShortV2(Duration.zero), '0p');
    });
  });
}
