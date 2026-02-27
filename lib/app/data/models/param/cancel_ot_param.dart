import 'package:json_annotation/json_annotation.dart';

part 'cancel_ot_param.g.dart';

@JsonSerializable(explicitToJson: true)
class CancelOtParam {
  @JsonKey()
  final String? note;

  CancelOtParam({
    required this.note,
  });

  factory CancelOtParam.fromJson(Map<String, dynamic> json) =>
      _$CancelOtParamFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOtParamToJson(this);
}