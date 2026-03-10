import 'package:json_annotation/json_annotation.dart';

part 'projects_param.g.dart';

@JsonSerializable()
class ProjectsParam {
  @JsonKey(name: 'project_id')
  final int? projectID;

  @JsonKey(name: 'project_name')
  final String? projectName;

  ProjectsParam({
    required this.projectID,
    required this.projectName,
  });

  factory ProjectsParam.fromJson(Map<String, dynamic> json) => _$ProjectsParamFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectsParamToJson(this);
}