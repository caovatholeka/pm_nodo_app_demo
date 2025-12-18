import 'package:json_annotation/json_annotation.dart';

part 'exception_line_param.g.dart';

@JsonSerializable()
class ExceptionLineParam {
  @JsonKey(name: "form_type")
  String? formType;

  @JsonKey(name: "time_number")
  double? timeNumber;

  ExceptionLineParam({
    this.formType,
    this.timeNumber,
  });

  factory ExceptionLineParam.fromJson(Map<String, dynamic> json) =>
      _$ExceptionLineParamFromJson(json);

  Map<String, dynamic> toJson() => _$ExceptionLineParamToJson(this);
}
