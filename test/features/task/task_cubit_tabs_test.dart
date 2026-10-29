import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';

Map<String, dynamic> _task(int id) => {
      'id': id,
      'name': 'Việc $id',
      'stage': {'code': 'in_progress', 'name': 'Đang thực hiện'},
      'user_ids': <dynamic>[],
    };

const _stagesJson = [
  {'id': 1, 'code': 'new', 'name': 'Mới'},
  {'id': 2, 'code': 'in_progress', 'name': 'Đang thực hiện'},
  {'id': 3, 'code': 'done', 'name': 'Hoàn thành'},
];

/// Repo giả: getListTask trả về theo từng Completer để điều khiển thứ tự kết quả.
class _FakeTaskRepository implements TaskRepository {
  final List<int?> requestedStageIds = [];
  final List<Completer<CommonResponse>> pending = [];
  Object? stagesError;

  @override
  Future<CommonResponse> getTaskStages() async {
    if (stagesError != null) throw stagesError!;
    return CommonResponse(data: _stagesJson);
  }

  @override
  Future<CommonResponse> getListTask(String? name, int? stageId, int? page, int? limit) {
    requestedStageIds.add(stageId);
    final c = Completer<CommonResponse>();
    pending.add(c);
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeTaskRepository repo;
  late TaskCubit cubit;

  setUp(() {
    repo = _FakeTaskRepository();
    cubit = TaskCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  test('mở lần đầu: sáng tab đầu và tải đúng việc của tab đầu', () async {
    await cubit.getListStages();
    expect(cubit.state.currentTabIndex, 0);
    expect(cubit.state.currentTabItem?.id, 1);
    expect(repo.requestedStageIds, [1]);
  });

  test('mở lại sau khi đã chọn "Đang thực hiện": tab sáng và dữ liệu cùng là tab đó', () async {
    // Lần mở trước người dùng chọn tab thứ 2 (cubit dùng chung giữa các lần mở màn)
    cubit.onChangeTab(1);
    cubit.onChangeCurrentTabItem(TaskStageEntity(id: 2, code: 'in_progress', name: 'Đang thực hiện'));

    await cubit.getListStages();
    expect(cubit.state.currentTabIndex, 1);
    expect(cubit.state.currentTabItem?.id, 2);
    // Trước đây tải việc của tab đầu (id 1) trong khi tab 2 đang sáng → "Không có dữ liệu"
    expect(repo.requestedStageIds, [2]);

    repo.pending.single.complete(CommonResponse(data: [_task(7)]));
    await _flush();
    expect(cubit.state.loadStatus, LoadStatus.SUCCESS);
    expect(cubit.state.listTasks?.map((e) => e.id), [7]);
  });

  test('giai đoạn đã lưu không còn → về tab đầu, tab sáng và bộ lọc vẫn khớp', () async {
    cubit.onChangeTab(2);
    cubit.onChangeCurrentTabItem(TaskStageEntity(id: 99, name: 'Đã xoá'));

    await cubit.getListStages();
    expect(cubit.state.currentTabIndex, 0);
    expect(cubit.state.currentTabItem?.id, 1);
    expect(repo.requestedStageIds, [1]);
  });

  test('kết quả của lần gọi cũ về sau không ghi đè danh sách mới', () async {
    cubit.getListTasks(); // lần 1 (cũ)
    cubit.getListTasks(); // lần 2 (mới nhất)
    expect(repo.pending.length, 2);

    repo.pending[1].complete(CommonResponse(data: [_task(2)]));
    await _flush();
    repo.pending[0].complete(CommonResponse(data: [_task(1)]));
    await _flush();

    expect(cubit.state.listTasks?.map((e) => e.id), [2]);
    expect(cubit.state.loadStatus, LoadStatus.SUCCESS);
  });

  test('lỗi tải giai đoạn vẫn tải danh sách, không kẹt loading', () async {
    repo.stagesError = Exception('network');
    await cubit.getListStages();
    expect(cubit.state.getStageStatus, LoadStatus.FAILURE);
    expect(repo.requestedStageIds.length, 1);

    repo.pending.single.complete(CommonResponse(data: [_task(3)]));
    await _flush();
    expect(cubit.state.loadStatus, LoadStatus.SUCCESS);
    expect(cubit.state.listTasks?.map((e) => e.id), [3]);
  });
}
