import 'package:json_annotation/json_annotation.dart';

part 'cp_work_bonus_ids_param.g.dart';

@JsonSerializable()
class CpWorkBonusIdsParam {
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

  @JsonKey()
  String? status;

  @JsonKey(name: "parent_note")
  String? parentNote;

  @JsonKey(name: "is_checked")
  bool? isChecked;

  CpWorkBonusIdsParam({
    this.dateFrom,
    this.dateTo,
    this.techniqueName,
    this.numberPeople,
    this.managerId,
    this.positionId,
    this.name,
    this.note,
    this.result,
    this.status,
    this.parentNote,
    this.isChecked,
  });

  CpWorkBonusIdsParam copyWith({
    String? dateFrom,
    String? dateTo,
    String? techniqueName,
    String? numberPeople,
    int? managerId,
    int? positionId,
    String? name,
    String? note,
    String? result,
    String? status,
    String? parentNote,
    bool? isChecked,
  }) {
    return CpWorkBonusIdsParam(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      techniqueName: techniqueName ?? this.techniqueName,
      numberPeople: numberPeople ?? this.numberPeople,
      managerId: managerId ?? this.managerId,
      positionId: positionId ?? this.positionId,
      name: name ?? this.name,
      note: note ?? this.note,
      result: result ?? this.result,
      status: status ?? this.status,
      parentNote: parentNote ?? this.parentNote,
      isChecked: isChecked ?? this.isChecked
    );
  }

  factory CpWorkBonusIdsParam.fromJson(Map<String, dynamic> json) => _$CpWorkBonusIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpWorkBonusIdsParamToJson(this);
}