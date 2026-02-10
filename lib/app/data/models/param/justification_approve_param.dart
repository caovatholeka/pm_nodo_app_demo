import 'package:json_annotation/json_annotation.dart';

part 'justification_approve_param.g.dart';

@JsonSerializable(explicitToJson: true)
class JustificationApproveParam {
  
  @JsonKey(name: 'exception_ids')
  final List<int> exceptionIds;

  JustificationApproveParam({
    required this.exceptionIds,
  });

  factory JustificationApproveParam.fromJson(Map<String, dynamic> json) =>
      _$JustificationApproveParamFromJson(json);
  Map<String, dynamic> toJson() => _$JustificationApproveParamToJson(this);
}