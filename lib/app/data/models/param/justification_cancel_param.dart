import 'package:json_annotation/json_annotation.dart';

part 'justification_cancel_param.g.dart';

@JsonSerializable(explicitToJson: true)
class JustificationCancelParam {
  @JsonKey()
  final String note;

  JustificationCancelParam({
    required this.note,
  });

  factory JustificationCancelParam.fromJson(Map<String, dynamic> json) =>
      _$JustificationCancelParamFromJson(json);
  Map<String, dynamic> toJson() => _$JustificationCancelParamToJson(this);
}