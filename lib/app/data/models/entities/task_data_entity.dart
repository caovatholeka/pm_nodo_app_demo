import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';

part 'task_data_entity.g.dart';

@JsonSerializable()
class TaskDataEntity {
  @JsonKey()
  int? total;

  @JsonKey()
  int? limit;

  @JsonKey()
  int? page;

  @JsonKey(name: "total_pages")
  int? totalPages;

  @JsonKey()
  List<TaskEntity>? items;

  TaskDataEntity({
    this.total,
    this.limit,
    this.page,
    this.totalPages,
    this.items,
  });

  TaskDataEntity copyWith({
    int? total,
    int? limit,
    int? page,
    int? totalPages,
    List<TaskEntity>? items,
  }) {
    return TaskDataEntity(
      total: total ?? this.total,
      limit: limit ?? this.limit,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      items: items ?? this.items,
    );
  }

  factory TaskDataEntity.fromJson(Map<String, dynamic> json) => _$TaskDataEntityFromJson(json);

  /// Danh sách task từ `data` của API /tasks/tasks. Backend hiện trả thẳng 1 mảng
  /// (từ 06/2026); bản cũ trả {total, ..., items: [...]} — nhận cả hai. Trước đây chỉ
  /// đọc dạng cũ nên danh sách "Việc cần làm" luôn rỗng.
  static List<TaskEntity> itemsFrom(dynamic data) {
    if (data is List) return mapList(data, TaskEntity.fromJson);
    return mapObject(data, TaskDataEntity.fromJson)?.items ?? [];
  }

  Map<String, dynamic> toJson() => _$TaskDataEntityToJson(this);
}