import 'package:json_annotation/json_annotation.dart';

part 'leave_approve_param.g.dart';

@JsonSerializable(explicitToJson: true)
class LeaveApproveParam {
  @JsonKey(name: 'leave_ids')
  final List<int> leaveIds;

  @JsonKey()
  final String? reason;

  LeaveApproveParam({
    required this.leaveIds,
    this.reason,
  });

  factory LeaveApproveParam.fromJson(Map<String, dynamic> json) =>
      _$LeaveApproveParamFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveApproveParamToJson(this);
}
