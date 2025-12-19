import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/work_shift_entity.dart';

part 'overtime_detail_entity.g.dart';
@JsonSerializable()
class OvertimeDetailEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? date;

  @JsonKey()
  int? overtime;

  @JsonKey(name: "form_type")
  String? formType;

  @JsonKey()
   WorkShiftEntity? shift;

  @JsonKey()
  String? note;

  OvertimeDetailEntity({
    required this.id,
    required this.date,
    required this.overtime,
    required this.formType,
    required this.shift,
    required this.note,
  });

  factory OvertimeDetailEntity.fromJson(Map<String, dynamic> json) =>
      _$OvertimeDetailEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeDetailEntityToJson(this);
}