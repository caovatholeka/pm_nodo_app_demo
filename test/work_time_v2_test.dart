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

  group('checkOutReminderAtV2', () {
    test('vào 08:30, chưa chấm ra -> nhắc lúc 18:00', () {
      final at = checkOutReminderAtV2(
          checkIn: _t(8, 30), checkOut: null, now: _t(9, 0));
      expect(at, _t(18, 0));
    });

    test('chưa chấm vào -> không nhắc', () {
      expect(
          checkOutReminderAtV2(checkIn: null, checkOut: null, now: _t(9, 0)),
          isNull);
    });

    test('đã chấm ra -> không nhắc', () {
      final at = checkOutReminderAtV2(
          checkIn: _t(8, 30), checkOut: _t(17, 0), now: _t(17, 5));
      expect(at, isNull);
    });

    test('đã qua giờ đủ công -> không hẹn (màn hình đã báo rồi)', () {
      final at = checkOutReminderAtV2(
          checkIn: _t(8, 30), checkOut: null, now: _t(18, 30));
      expect(at, isNull);
    });

    test('vào muộn 10:00 -> nhắc lúc 19:30 (8h + 1h30 nghỉ trưa)', () {
      final at = checkOutReminderAtV2(
          checkIn: _t(10, 0), checkOut: null, now: _t(10, 5));
      expect(at, _t(19, 30));
    });
  });

  group('showWorkProgressV2 (chỉ hiện khi vào đúng giờ / muộn tối đa 15 phút)', () {
    final ca8 = _t(8, 0); // ca bắt đầu 08:00

    test('vào trước giờ ca -> hiện', () {
      expect(showWorkProgressV2(checkIn: _t(7, 50), shiftStart: ca8), isTrue);
    });
    test('vào đúng giờ ca -> hiện', () {
      expect(showWorkProgressV2(checkIn: _t(8, 0), shiftStart: ca8), isTrue);
    });
    test('muộn đúng 15 phút (kể cả giây lẻ) -> hiện', () {
      expect(showWorkProgressV2(checkIn: _t(8, 15), shiftStart: ca8), isTrue);
      expect(
          showWorkProgressV2(
              checkIn: DateTime(2026, 7, 24, 8, 15, 59), shiftStart: ca8),
          isTrue);
    });
    test('muộn 16 phút -> ẩn', () {
      expect(showWorkProgressV2(checkIn: _t(8, 16), shiftStart: ca8), isFalse);
    });
    test('chưa chấm vào -> ẩn', () {
      expect(showWorkProgressV2(checkIn: null, shiftStart: ca8), isFalse);
    });
    test('không có ca -> so với 08:30', () {
      expect(showWorkProgressV2(checkIn: _t(8, 45)), isTrue);
      expect(showWorkProgressV2(checkIn: _t(8, 46)), isFalse);
    });
  });
}
