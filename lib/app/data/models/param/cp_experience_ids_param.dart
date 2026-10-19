import 'package:json_annotation/json_annotation.dart';

part 'cp_experience_ids_param.g.dart';

@JsonSerializable()
class CpExperienceIdsParam {
  @JsonKey(name: "date_from")
  String? dateFrom;

  @JsonKey(name: "date_to")
  String? dateTo;

  @JsonKey(name: "technique_name")
  String? techniqueName;

  @JsonKey(name: "number_people")
  String? numberPeople;

  @JsonKey(name: "manager_id")
  int? managerId;

  @JsonKey(name: "position_id")
  int? positionId;

  @JsonKey()
  String? name;

  @JsonKey()
  String? note;

  @JsonKey()
  String? result;

  @JsonKey(name: "parent_note")
  String? parentNote;

  @JsonKey(name: "is_checked")
  bool? isChecked;

  @JsonKey()
  String? rate;
  CpExperienceIdsParam({
    this.dateFrom,
    this.dateTo,
    this.techniqueName,
    this.numberPeople,
    this.managerId,
    this.positionId,
    this.name,
    this.note,
    this.result,
    this.rate,
    this.parentNote,
    this.isChecked,
  });

  CpExperienceIdsParam copyWith({
    String? dateFrom,
    String? dateTo,
    String? techniqueName,
    String? numberPeople,
    int? managerId,
    int? positionId,
    String? name,
    String? note,
    String? result,
    String? rate,
    String? parentNote,
    bool? isChecked,
  }) {
    return CpExperienceIdsParam(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      techniqueName: techniqueName ?? this.techniqueName,
      numberPeople: numberPeople ?? this.numberPeople,
      managerId: managerId ?? this.managerId,
      positionId: positionId ?? this.positionId,
      name: name ?? this.name,
      note: note ?? this.note,
      result: result ?? this.result,
      rate: rate ?? this.rate,
      parentNote: parentNote ?? this.parentNote,
      isChecked: isChecked ?? this.isChecked
    );
  }

  factory CpExperienceIdsParam.fromJson(Map<String, dynamic> json) => _$CpExperienceIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpExperienceIdsParamToJson(this);
}