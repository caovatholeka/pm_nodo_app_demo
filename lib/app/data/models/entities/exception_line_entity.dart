import 'package:json_annotation/json_annotation.dart';

part 'exception_line_entity.g.dart';

@JsonSerializable()
class ExceptionLineEntity {
  @JsonKey()
  int? id;

  @JsonKey(name: 'form_type')
  String? formType;

  @JsonKey(name: 'time_number')
  double? timeNumber;

  @JsonKey()
  String? state;

  ExceptionLineEntity({
    this.id,
    this.formType,
    this.timeNumber,
    this.state,
  });

  factory ExceptionLineEntity.fromJson(Map<String, dynamic> json) =>
      _$ExceptionLineEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ExceptionLineEntityToJson(this);
}
