import 'package:json_annotation/json_annotation.dart';

part 'cp_character_ids_param.g.dart';

@JsonSerializable()
class CpCharacterIdsParam {
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
  
  CpCharacterIdsParam({
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

  CpCharacterIdsParam copyWith({
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
    return CpCharacterIdsParam(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      note: note ?? this.note,
      ratePoint: ratePoint ?? this.ratePoint,
      parentNote: parentNote ?? this.parentNote,
      isChecked: isChecked ?? this.isChecked,
      hrChecked: hrChecked ?? this.hrChecked,
      hrNote: hrNote ?? this.hrNote,
      hrRatePoint: hrRatePoint ?? hrRatePoint,
    );
  }

  factory CpCharacterIdsParam.fromJson(Map<String, dynamic> json) => _$CpCharacterIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpCharacterIdsParamToJson(this);
}