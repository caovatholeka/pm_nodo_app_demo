  import 'package:json_annotation/json_annotation.dart';

part 'create_task_param.g.dart';

@JsonSerializable()
class CreateTaskParam {
  @JsonKey(name: "task_id")
  String? taskId;

  @JsonKey()
  String? name;

  @JsonKey(name: "date_deadline")
  String? deadLine;

  @JsonKey(name: "description")
  String? desc;

  @JsonKey(name: "user_ids")
  List<int>? userIds;

  @JsonKey(name: "priority")
  int? priority;

  CreateTaskParam({
    this.taskId,
    this.name,
    this.deadLine,
    this.desc,
    this.userIds,
    this.priority,
  });

  CreateTaskParam copyWith({
    String? taskId,
    String? name,
    String? deadLine,
    String? desc,
    List<int>? userIds,
    int? priority,
  }) {
    return CreateTaskParam(
      taskId: taskId ?? this.taskId,
        name: name ?? this.name,
        deadLine: deadLine ?? this.deadLine,
        desc: desc ?? this.desc,
        userIds: userIds ?? this.userIds,
        priority: priority ?? this.priority,
    );
  }

  factory CreateTaskParam.fromJson(Map<String, dynamic> json) => _$CreateTaskParamFromJson(json);

  // Map<String, dynamic> toJson() => _$CreateTaskParamToJson(this);
  Map<String, dynamic> toJson(){
    final map = _$CreateTaskParamToJson(this);
    map.removeWhere((key, value) =>
    value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty));
    return map;
  }
}