import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';

part 'create_overtime_param.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateOvertimeParam {
  @JsonKey(name: 'from_date')
  final String fromDate;

  @JsonKey(name: 'to_date')
  final String toDate;

  @JsonKey()
  final String? note;

  @JsonKey(name: 'overtime_lines')
  final List<OvertimeLineEntity> overtimeLines;

  CreateOvertimeParam({
    required this.fromDate,
    required this.toDate,
    this.note,
    required this.overtimeLines,
  });

  factory CreateOvertimeParam.fromJson(Map<String, dynamic> json) =>
      _$CreateOvertimeParamFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOvertimeParamToJson(this);
}
