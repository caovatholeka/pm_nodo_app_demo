import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/param/cp_character_ids_param.dart';
import 'package:pm_app/app/data/models/param/cp_experience_ids_param.dart';
import 'package:pm_app/app/data/models/param/cp_plan_ids_param.dart';
import 'package:pm_app/app/data/models/param/cp_self_plan_ids_param.dart';
import 'package:pm_app/app/data/models/param/cp_skill_ids_param.dart';
import 'package:pm_app/app/data/models/param/cp_work_bonus_ids_param.dart';

part 'checkpoint_entity.g.dart';

@JsonSerializable()
class CheckpointEntity {
  @JsonKey(fromJson: _checkpointIntFromJson)
  int? id;

  @JsonKey()
  String? name;

  @JsonKey(name: "employee_id")
  int? employeeId;

  @JsonKey(name: "employee_name")
  String? employeeName;

  @JsonKey()
  String? employee;

  @JsonKey(name: "employee_code")
  String? employeeCode;

  @JsonKey(name: "department_id")
  int? departmentId;

  @JsonKey(name: "department_name")
  String? departmentName;

  @JsonKey(name: "manager_name")
  String? managerName;

  @JsonKey()
  String? parent;

  @JsonKey(name: "date_from")
  String? dateFrom;

  @JsonKey(name: "date_to")
  String? dateTo;

  @JsonKey()
  String? note;

  @JsonKey()
  String? state;

  @JsonKey()
  String? stage;

  @JsonKey(name: "employee_note")
  String? employeeNote;

  @JsonKey(name: "character_ids")
  List<CpCharacterIdsParam>? characterIds;

  @JsonKey(name: "skill_ids")
  List<CpSkillIdsParam>? skillIds;

  @JsonKey(name: "experience_ids")
  List<CpExperienceIdsParam>? experienceIds;

  @JsonKey(name: "work_bonus_ids")
  List<CpWorkBonusIdsParam>? workBonusIds;

  @JsonKey(name: "plan_ids")
  List<CpPlanIdsParam>? planIds;

  @JsonKey(name: "self_plan_ids")
  List<CpSelfPlanIdsParam>? selfPlanIds;

  CheckpointEntity();

  factory CheckpointEntity.fromJson(Map<String, dynamic> json) =>
      _$CheckpointEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CheckpointEntityToJson(this);
}

int? _checkpointIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
