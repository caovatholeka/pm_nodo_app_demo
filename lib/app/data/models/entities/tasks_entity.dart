import 'package:json_annotation/json_annotation.dart';

part 'tasks_entity.g.dart';

@JsonSerializable()
class TasksEntity {
  @JsonKey(name: 'task_id')
  final int? taskID;

  @JsonKey(name: 'task_name')
  final String? taskName;

  @JsonKey()
  final String? deadline;

  @JsonKey(name: 'assigned_employee_id')
  final int? assignedEmployeeID;

  @JsonKey(name: 'assigned_employee_name')
  final String? assignedEmployeeName;

  @JsonKey()
  final String? stage;

  @JsonKey()
  final List<String>? tags;

  @JsonKey(name: 'is_favourite')
  final bool? isFavorite;

  TasksEntity({
    required this.taskID,
    required this.taskName,
    required this.deadline,
    required this.assignedEmployeeID,
    required this.assignedEmployeeName,
    required this.stage,
    required this.tags,
    required this.isFavorite,
  });

    factory TasksEntity.fromJson(Map<String, dynamic> json) => _$TasksEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TasksEntityToJson(this);
}