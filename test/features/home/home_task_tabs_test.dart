import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/ui/home/home_cubit.dart';

Map<String, dynamic> _task(int id, String name) => {
      'id': id,
      'name': name,
      'stage': {'code': 'x', 'name': 'x'},
      'user_ids': const [],
    };

class _Repo extends Fake implements TaskRepository {
  final List<int?> asked = [];

  /// Kết quả theo id trạng thái; completer để giả lập mạng chậm.
  final Map<int, Completer<CommonResponse>> pending = {};
  bool slow = false;

  @override
  Future<CommonResponse> getTaskStages() async => CommonResponse(data: [
        // Thứ tự từ API khác thứ tự tab mong muốn
        {'id': 3, 'code': 'done', 'name': 'Hoàn thành'},
        {'id': 1, 'code': 'new', 'name': 'Mới'},
        {'id': 4, 'code': 'rejected', 'name': 'Từ chối'},
        {'id': 2, 'code': 'in_progress', 'name': 'Đang thực hiện'},
      ]);

  @override
  Future<CommonResponse> getListTask(
      String? name, int? stageId, int? page, int? limit) {
    asked.add(stageId);
    final res = CommonResponse(data: [_task(stageId! * 10, 'Việc của trạng thái $stageId')]);
    if (!slow) return Future.value(res);
    final c = Completer<CommonResponse>();
    pending[stageId] = c;
    return c.future.then((_) => res);
  }
}

class _NoUser extends Fake implements UserRepository {}

void main() {
  test('tab sắp theo Mới / Đang thực hiện / Hoàn thành / Từ chối, mặc định Mới', () async {
    final repo = _Repo();
    final cubit = HomeCubit(userRepository: _NoUser(), taskRepository: repo);
    await cubit.getListNewTasks();
    await cubit.loadHomeTaskStages();

    expect(cubit.state.homeTaskStages.map((e) => e.name),
        ['Mới', 'Đang thực hiện', 'Hoàn thành', 'Từ chối']);
    expect(cubit.state.homeTaskStageId, 1);
    expect(repo.asked, [1]); // không tải lại khi tab mặc định đã đúng
    expect(cubit.state.listNewTasks!.single.id, 10);
    await cubit.close();
  });

  test('bấm tab "Hoàn thành" → tải việc của trạng thái đó', () async {
    final repo = _Repo();
    final cubit = HomeCubit(userRepository: _NoUser(), taskRepository: repo);
    await cubit.loadHomeTaskStages();
    await cubit.selectHomeTaskStage(3);

    expect(cubit.state.homeTaskStageId, 3);
    expect(repo.asked.last, 3);
    expect(cubit.state.listNewTasks!.single.name, 'Việc của trạng thái 3');
    await cubit.close();
  });

  test('bấm nhanh sang tab khác: kết quả tab cũ về sau không ghi đè', () async {
    final repo = _Repo()..slow = true;
    final cubit = HomeCubit(userRepository: _NoUser(), taskRepository: repo);

    final f2 = cubit.selectHomeTaskStage(2);
    final f4 = cubit.selectHomeTaskStage(4);
    repo.pending[4]!.complete(CommonResponse());
    await f4;
    repo.pending[2]!.complete(CommonResponse()); // tab 2 trả về muộn
    await f2;

    expect(cubit.state.homeTaskStageId, 4);
    expect(cubit.state.listNewTasks!.single.id, 40);
    await cubit.close();
  });
}
