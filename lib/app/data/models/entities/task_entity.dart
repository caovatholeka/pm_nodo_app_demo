import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';

part 'task_entity.g.dart';

@JsonSerializable()
class TaskEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey()
  TaskStageEntity? stage;

  @JsonKey()
  String? description;

  @JsonKey(name: "date_deadline")
  String? deadline;

  @JsonKey()
  String? priority;

  @JsonKey()
  UserEntity? assigner;

  @JsonKey(name: "user_ids")
  List<UserEntity>? userIds;

  @JsonKey(name: "task_type")
  String? taskType;

  @JsonKey(name: "created_date")
  String? createdDate;

  TaskEntity({
    this.id,
    this.name,
    this.stage,
    this.description,
    this.deadline,
    this.priority,
    this.assigner,
    this.userIds,
    this.taskType,
    this.createdDate
  });

  TaskEntity copyWith({
    int? id,
    String? name,
    TaskStageEntity? stage,
    String? description,
    String? deadline,
    String? priority,
    UserEntity? assigner,
    List<UserEntity>? userIds,
    String? taskType,
    String? createdDate
}) {
    return TaskEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        stage: stage ?? this.stage,
        description: description ?? this.description,
        deadline: deadline ?? this.deadline,
        priority: priority ?? this.priority,
        assigner: assigner ?? this.assigner,
        userIds: userIds ?? this.userIds,
        taskType: taskType ?? this.taskType,
      createdDate: createdDate ?? this.createdDate
    );
  }

  factory TaskEntity.fromJson(Map<String, dynamic> json) => _$TaskEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskEntityToJson(this);
}