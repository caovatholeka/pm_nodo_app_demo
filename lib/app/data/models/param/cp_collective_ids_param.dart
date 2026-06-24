import 'package:json_annotation/json_annotation.dart';

part 'cp_collective_ids_param.g.dart';

@JsonSerializable()
class CpCollectiveIdsParam {
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

  CpCollectiveIdsParam({
    this.code,
    this.name,
    this.note,
    this.ratePoint,
    this.parentNote,
    this.isChecked,
  });

  CpCollectiveIdsParam copyWith({
    String? code,
    String? name,
    String? note,
    int? ratePoint,
    String? parentNote,
    bool? isChecked,
  }) {
    return CpCollectiveIdsParam(
      code: code ?? this.code,
      name: name ?? this.name,
      note: note ?? this.note,
      ratePoint: ratePoint ?? this.ratePoint,
      parentNote: parentNote ?? this.parentNote,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory CpCollectiveIdsParam.fromJson(Map<String, dynamic> json) => _$CpCollectiveIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpCollectiveIdsParamToJson(this);
}