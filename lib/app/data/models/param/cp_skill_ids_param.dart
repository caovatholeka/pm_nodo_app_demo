import 'package:json_annotation/json_annotation.dart';

part 'cp_skill_ids_param.g.dart';

@JsonSerializable()
class CpSkillIdsParam {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey()
  String? note;

  @JsonKey(name: "rate_point")
  int? ratePoint;

  @JsonKey(name: "parent_note")
  String? parentNote;

  @JsonKey(name: "is_checked")
  bool? isChecked;

  @JsonKey(name: "hr_rate_point")
  int? hrRatePoint;

  @JsonKey(name: "hr_note")
  String? hrNote;

  @JsonKey(name: "hr_checked")
  bool? hrChecked;
  
  CpSkillIdsParam({
    this.id,
    this.code,
    this.name,
    this.note,
    this.ratePoint,
    this.parentNote,
    this.isChecked,
    this.hrChecked,
    this.hrNote,
    this.hrRatePoint,
  });

  CpSkillIdsParam copyWith({
    int? id,
    String? code,
    String? name,
    String? note,
    int? ratePoint,
    String? parentNote,
    bool? isChecked,
    int? hrRatePoint,
    String? hrNote,
    bool? hrChecked,
  }) {
    return CpSkillIdsParam(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      note: note ?? this.note,
      ratePoint: ratePoint ?? this.ratePoint,
      parentNote: parentNote ?? this.parentNote,
      isChecked: isChecked ?? this.isChecked,
      hrChecked: hrChecked ?? this.hrChecked,
      hrNote: hrNote ?? this.hrNote,
      hrRatePoint: hrRatePoint ?? this.hrRatePoint
    );
  }

  factory CpSkillIdsParam.fromJson(Map<String, dynamic> json) => _$CpSkillIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpSkillIdsParamToJson(this);
}