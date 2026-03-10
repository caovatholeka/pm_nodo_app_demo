import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/param/projects_param.dart';

part 'projects_entity.g.dart';

@JsonSerializable()
class ProjectsEntity {
  @JsonKey()
  final List<ProjectsParam> projects;

  ProjectsEntity({
    required this.projects
  });

  factory ProjectsEntity.fromJson(Map<String, dynamic> json) => _$ProjectsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectsEntityToJson(this);
}