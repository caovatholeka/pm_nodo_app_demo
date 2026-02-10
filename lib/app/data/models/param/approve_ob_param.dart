import 'package:json_annotation/json_annotation.dart';

part 'approve_ob_param.g.dart';

@JsonSerializable(explicitToJson: true)
class ApproveObParam {
  @JsonKey(name: 'business_ids')
  final List<int> businessIds;

  ApproveObParam({
    required this.businessIds,
  });

  factory ApproveObParam.fromJson(Map<String, dynamic> json) =>
      _$ApproveObParamFromJson(json);

  Map<String, dynamic> toJson() => _$ApproveObParamToJson(this);
}