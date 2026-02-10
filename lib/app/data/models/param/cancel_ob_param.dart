import 'package:json_annotation/json_annotation.dart';

part 'cancel_ob_param.g.dart';

@JsonSerializable(explicitToJson: true)
class CancelObParam {
  @JsonKey()
  final String note;

  CancelObParam({
    required this.note,
  });

  factory CancelObParam.fromJson(Map<String, dynamic> json) =>
      _$CancelObParamFromJson(json);
  Map<String, dynamic> toJson() => _$CancelObParamToJson(this);
}