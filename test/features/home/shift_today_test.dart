import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/data/models/entities/shift_of_day_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';
import 'package:pm_app/app/features/ui_v2/home/work_time_v2.dart';

final _day = DateTime(2026, 10, 16);
DateTime _t(int h, [int m = 0]) => DateTime(2026, 10, 16, h, m);

Map<String, dynamic> _row(String name, num from, num to) => {
      'id': 1,
      'shift': {'id': 1, 'name': name, 'hour_from': from, 'hour_to': to},
      'datetime_from': null,
      'datetime_to': null,
    };

class _ShiftRepo extends Fake implements UserRepository {
  _ShiftRepo(this.answer);
  Object answer; // CommonResponse hoặc Exception
  @override
  Future<CommonResponse> getShiftAsDay(String date) async {
    final a = answer;
    if (a is Exception) throw a;
    return a as CommonResponse;
  }
}

class _NoTasks extends Fake implements TaskRepository {}

void main() {
  group('ShiftOfDayEntity.fromApiData', () {
    test('ca OS1 8:00–17:30', () {
      final s = ShiftOfDayEntity.fromApiData([_row('OS1', 8.0, 17.5)], _day)!;
      expect((s.name, s.start, s.end, s.isDayOff), ('OS1', _t(8), _t(17, 30), false));
    });
    test('ca HC 8:30–18:00 (giờ lẻ)', () {
      final s = ShiftOfDayEntity.fromApiData([_row('HC', 8.5, 18)], _day)!;
      expect((s.start, s.end), (_t(8, 30), _t(18)));
    });
    test('ngày nghỉ CT 0:00–0:00 → isDayOff', () {
      expect(ShiftOfDayEntity.fromApiData([_row('CT', 0, 0)], _day)!.isDayOff, isTrue);
    });
    test('ca qua đêm 22:00–06:00 → kết thúc ngày hôm sau', () {
      final s = ShiftOfDayEntity.fromApiData([_row('Đêm', 22, 6)], _day)!;
      expect(s.end, DateTime(2026, 10, 17, 6));
      expect(s.isDayOff, isFalse);
    });
    test('không có ca / dữ liệu lạ → null; bỏ qua dòng không gắn ca', () {
      expect(ShiftOfDayEntity.fromApiData([], _day), isNull);
      expect(ShiftOfDayEntity.fromApiData(null, _day), isNull);
      expect(ShiftOfDayEntity.fromApiData({'error': true}, _day), isNull);
      final s = ShiftOfDayEntity.fromApiData([
        {'id': 2, 'shift': null},
        _row('OS2', 8, 12),
      ], _day)!;
      expect(s.name, 'OS2');
    });
    test('hour_from dạng chuỗi vẫn đọc được', () {
      final s = ShiftOfDayEntity.fromApiData([_row('HC', 8.5, 18)..['shift']['hour_from'] = '8.5'], _day)!;
      expect(s.start, _t(8, 30));
    });
  });

  group('computeWorkProgressV2 theo ca được phân', () {
    test('OS1: vào 08:00 → ra lúc 17:30, cần 8h', () {
      final p = computeWorkProgressV2(
          checkIn: _t(8), now: _t(9), shiftStart: _t(8), shiftEnd: _t(17, 30))!;
      expect((p.required, p.earliestOut), (const Duration(hours: 8), _t(17, 30)));
    });
    test('HC: vào sớm 08:10 → vẫn ra lúc 18:00 (không gợi ý ra trước giờ hết ca)', () {
      final p = computeWorkProgressV2(
          checkIn: _t(8, 10), now: _t(17, 40), shiftStart: _t(8, 30), shiftEnd: _t(18))!;
      expect(p.earliestOut, _t(18));
      expect(p.remaining, const Duration(minutes: 20));
      expect(p.done, isFalse);
    });
    test('HC: vào muộn 09:00 → ra lúc 18:30 để đủ 8h (như quy tắc cũ)', () {
      final p = computeWorkProgressV2(
          checkIn: _t(9), now: _t(10), shiftStart: _t(8, 30), shiftEnd: _t(18))!;
      expect(p.earliestOut, _t(18, 30));
    });
    test('OS2 nửa ngày 8:00–12:00 → cần 4h, ra lúc 12:00, 12:00 là xong', () {
      final p = computeWorkProgressV2(
          checkIn: _t(8), now: _t(12), shiftStart: _t(8), shiftEnd: _t(12))!;
      expect((p.required, p.earliestOut, p.done), (const Duration(hours: 4), _t(12), true));
    });
    test('vào sớm 07:50, ca 08:00 → giờ làm tính từ 08:00 (thanh không đầy trước giờ ra)', () {
      final p = computeWorkProgressV2(
          checkIn: _t(7, 50), now: _t(10), shiftStart: _t(8), shiftEnd: _t(17, 30))!;
      expect(p.worked, const Duration(hours: 2)); // 08:00 → 10:00, không phải 2h10
      expect(p.earliestOut, _t(17, 30));
      expect(p.remaining, const Duration(hours: 6));
      // Lúc 17:20: chưa đủ (trước đây thanh đã đầy 100% vì tính từ 07:50)
      final late = computeWorkProgressV2(
          checkIn: _t(7, 50), now: _t(17, 20), shiftStart: _t(8), shiftEnd: _t(17, 30))!;
      expect(late.worked < late.required, isTrue);
      expect(late.done, isFalse);
    });
    test('vào sớm, chưa tới giờ ca → còn nguyên số giờ cần đạt', () {
      final p = computeWorkProgressV2(
          checkIn: _t(7, 50), now: _t(7, 55), shiftStart: _t(8), shiftEnd: _t(17, 30))!;
      expect((p.worked, p.remaining), (Duration.zero, const Duration(hours: 8)));
    });
    test('không có ca nhưng có mốc 08:30: vào 08:00 → tính từ 08:30, ra 18:00', () {
      final p = computeWorkProgressV2(checkIn: _t(8), now: _t(9), shiftStart: _t(8, 30))!;
      expect((p.required, p.worked, p.earliestOut),
          (const Duration(hours: 8), const Duration(minutes: 30), _t(18)));
    });
    test('giờ nhắc chấm ra = giờ "Ra lúc" theo ca', () {
      final at = checkOutReminderAtV2(
          checkIn: _t(7, 50), checkOut: null, now: _t(9),
          shiftStart: _t(8), shiftEnd: _t(17, 30));
      expect(at, _t(17, 30));
    });
    test('không có ca → giữ quy tắc 8 tiếng như cũ', () {
      final p = computeWorkProgressV2(checkIn: _t(8, 30), now: _t(11))!;
      expect((p.required, p.earliestOut, p.remaining),
          (const Duration(hours: 8), _t(18), const Duration(hours: 5, minutes: 30)));
    });
  });

  group('HomeCubit.getShiftToday', () {
    test('tải được ca → state.shiftToday', () async {
      final repo = _ShiftRepo(CommonResponse(data: [_row('OS1', 8, 17.5)]));
      final cubit = HomeCubit(userRepository: repo, taskRepository: _NoTasks());
      await cubit.getShiftToday();
      expect(cubit.state.shiftToday?.name, 'OS1');
      await cubit.close();
    });
    test('lỗi mạng → giữ ca đã có, không làm hỏng state', () async {
      final repo = _ShiftRepo(CommonResponse(data: [_row('HC', 8.5, 18)]));
      final cubit = HomeCubit(userRepository: repo, taskRepository: _NoTasks());
      await cubit.getShiftToday();
      repo.answer = Exception('offline');
      await cubit.getShiftToday();
      expect(cubit.state.shiftToday?.name, 'HC');
      await cubit.close();
    });
    test('chưa được phân ca → SUCCESS + null (Home hiện "Chưa phân ca")', () async {
      final repo = _ShiftRepo(CommonResponse(data: const []));
      final cubit = HomeCubit(userRepository: repo, taskRepository: _NoTasks());
      expect(cubit.state.shiftStatus, LoadStatus.INITIAL);
      await cubit.getShiftToday();
      expect((cubit.state.shiftStatus, cubit.state.shiftToday),
          (LoadStatus.SUCCESS, null));
      await cubit.close();
    });
    test('lỗi mạng lần đầu → FAILURE (Home không khẳng định "Chưa phân ca")', () async {
      final repo = _ShiftRepo(Exception('offline'));
      final cubit = HomeCubit(userRepository: repo, taskRepository: _NoTasks());
      await cubit.getShiftToday();
      expect(cubit.state.shiftStatus, LoadStatus.FAILURE);
      await cubit.close();
    });
  });
}
