import 'package:json_annotation/json_annotation.dart';

part 'leave_reject_param.g.dart';

@JsonSerializable(explicitToJson: true)
class LeaveRejectParam {
  @JsonKey()
  final String? note;

  LeaveRejectParam({
    required this.note,
  });

  factory LeaveRejectParam.fromJson(Map<String, dynamic> json) =>
      _$LeaveRejectParamFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveRejectParamToJson(this);
}