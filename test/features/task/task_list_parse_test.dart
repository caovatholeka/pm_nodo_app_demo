import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/data/models/entities/task_data_entity.dart';

/// 1 task đúng như backend hiện tại trả về (GET /tasks/tasks, nodo_hr_api/handler/tasks_handle.py).
Map<String, dynamic> _task(int id, {Object? taskType}) => {
      'id': id,
      'name': 'Việc $id',
      'stage': {'code': 'new', 'name': 'Mới'},
      'description': null,
      'date_deadline': '2026-10-25 17:00:00',
      'deadline_state': 'on_track',
      'deadline_badge': 'Còn 4 ngày',
      'priority': '0',
      'assigner': {'id': 75, 'name': 'Người giao'},
      'user_ids': [
        {'id': 75, 'name': 'Người giao'},
      ],
      'task_type': taskType,
      'created_date': '2026-10-21 09:00:00',
    };

void main() {
  test('backend mới: data là mảng, task_type là {code, name}', () {
    final items = TaskDataEntity.itemsFrom([
      _task(2, taskType: {'code': 'normal', 'name': 'Công việc thường'}),
      _task(1, taskType: null),
    ]);
    expect(items.map((e) => e.id), [2, 1]);
    expect(items.first.taskType, 'normal');
    expect(items.first.stage?.code, 'new');
    expect(items.first.userIds?.single.id, 75);
    expect(items.last.taskType, isNull);
  });

  test('backend cũ: data là {items: [...]}, task_type là chuỗi', () {
    final items = TaskDataEntity.itemsFrom({
      'total': 1,
      'limit': 100,
      'page': 1,
      'total_pages': 1,
      'items': [_task(5, taskType: 'normal')],
    });
    expect(items.single.id, 5);
    expect(items.single.taskType, 'normal');
  });

  test('không có dữ liệu → danh sách rỗng', () {
    expect(TaskDataEntity.itemsFrom(null), isEmpty);
    expect(TaskDataEntity.itemsFrom(<dynamic>[]), isEmpty);
  });
}
