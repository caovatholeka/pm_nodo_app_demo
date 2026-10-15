import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/check_in_out_entity.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';

/// Trả lịch sử chấm công hôm nay như API /attendance/history (mới nhất trước).
class _FakeUserRepository extends Fake implements UserRepository {
  List<Map<String, dynamic>> history = [];
  int calls = 0;

  @override
  Future<CommonResponse> getListAttendanceToday(String? dateFrom, String? dateTo) async {
    calls++;
    return CommonResponse(data: history);
  }
}

class _FakeTaskRepository extends Fake implements TaskRepository {}

Map<String, dynamic> _row(int id, String action, String time) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return {
    'id': id,
    'action': action,
    'action_raw': action,
    'datetime': '$today $time',
    'date': today,
    'attendance_explanation': null,
    'location': {'id': 1, 'name': 'Văn phòng nodo'},
    'distance': 30.33,
    'has_face_image': true,
    'is_late': false,
    'is_early': false,
  };
}

void main() {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late _FakeUserRepository userRepo;
  late HomeCubit cubit;

  setUp(() {
    userRepo = _FakeUserRepository();
    cubit = HomeCubit(userRepository: userRepo, taskRepository: _FakeTaskRepository());
  });

  tearDown(() => cubit.close());

  test('tải lịch sử hôm nay: giờ vào = lượt vào, giờ ra = lượt ra mới nhất', () async {
    userRepo.history = [
      _row(48592, 'check_out', '16:38:55'),
      _row(48585, 'check_out', '15:36:08'),
      _row(48416, 'check_in', '14:20:01'),
    ];
    await cubit.getListAttendanceToday();
    expect(cubit.state.checkInToday, '$today 14:20:01');
    expect(cubit.state.checkOutToday, '$today 16:38:55');
  });

  test('sau khi chấm ra: khớp theo id, giữ giờ vào, giờ ra lấy từ lịch sử (server cũ trả UTC)', () async {
    userRepo.history = [_row(48416, 'check_in', '14:20:01')];
    await cubit.getListAttendanceToday();

    userRepo.history = [
      _row(48600, 'check_out', '18:00:05'),
      _row(48416, 'check_in', '14:20:01'),
    ];
    // Server cũ trả datetime theo UTC (18:00 VN = 11:00 UTC)
    await cubit.handleAttendanceSubmitted(
      CheckInOutEntity(id: 48600, action: 'check_out', datetime: '$today 11:00:05'),
    );

    expect(cubit.state.checkInToday, '$today 14:20:01');
    expect(cubit.state.checkOutToday, '$today 18:00:05');
    expect(userRepo.calls, 2, reason: 'đồng bộ khớp ngay lần đầu, không gọi lại nhiều lần');
  });
}
