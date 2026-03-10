import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/tasks_entity.dart';

part 'project_tasks_entity.g.dart';

@JsonSerializable()
class ProjectTasksEntity {
  @JsonKey(name: 'project_id')
  final int? projectID;

  @JsonKey(name: 'project_name')
  final String? projectName;

  @JsonKey()
  final int? total; 

  @JsonKey()
  final int? limit;

  @JsonKey()
   final int? page; 

  @JsonKey(name: 'total_pages')
  final int? totalPages;

  @JsonKey()
  final List<TasksEntity>? tasks;

  ProjectTasksEntity({
    required this.projectID,
    required this.projectName,
    required this.total,
    required this.limit,
    required this.page,
    required this.tasks,
    required this.totalPages,
  });

  factory ProjectTasksEntity.fromJson(Map<String, dynamic> json) => _$ProjectTasksEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectTasksEntityToJson(this);
}