import 'package:json_annotation/json_annotation.dart';

part 'ot_approve_param.g.dart';

@JsonSerializable(explicitToJson: true)
class OtApproveParam {
  @JsonKey(name: 'overtime_ids')
  final List<int> overtimeIds;

  OtApproveParam({
    required this.overtimeIds,
  });

  factory OtApproveParam.fromJson(Map<String, dynamic> json) =>
      _$OtApproveParamFromJson(json);
  Map<String, dynamic> toJson() => _$OtApproveParamToJson(this);
}