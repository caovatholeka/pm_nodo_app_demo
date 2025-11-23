import 'package:json_annotation/json_annotation.dart';
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

  Map<String, dynamic> toJson() => _$TaskDataEntityToJson(this);
}