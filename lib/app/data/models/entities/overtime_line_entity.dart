import 'package:json_annotation/json_annotation.dart';

part 'overtime_line_entity.g.dart';

@JsonSerializable()
class OvertimeLineEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? date;

  @JsonKey(name: 'form_type')
  String? formType; // pay | leave

  @JsonKey()
  double? overtime;

  OvertimeLineEntity({
    this.id,
    this.date,
    this.formType,
    this.overtime,
  });

  factory OvertimeLineEntity.fromJson(Map<String, dynamic> json) =>
      _$OvertimeLineEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeLineEntityToJson(this);
}
