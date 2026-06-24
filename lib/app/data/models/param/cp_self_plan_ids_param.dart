import 'package:json_annotation/json_annotation.dart';

part 'cp_self_plan_ids_param.g.dart';

@JsonSerializable()
class CpSelfPlanIdsParam {
  @JsonKey()
  String? name;

  @JsonKey()
  String? timeline;

  @JsonKey(name: "expected_result")
  String? expectedResult;

  @JsonKey(name: "manager_review_note")
  String? managerReviewNote;

  @JsonKey(name: "is_checked")
  bool? isChecked;

  @JsonKey()
  String? suggestion;
  CpSelfPlanIdsParam({
    this.name,
    this.timeline,
    this.expectedResult,
    this.suggestion,
    this.managerReviewNote,
    this.isChecked,
  });

  CpSelfPlanIdsParam copyWith({
    String? name,
    String? timeline,
    String? expectedResult,
    String? suggestion,
    String? managerReviewNote,
    bool? isChecked,
  }) {
    return CpSelfPlanIdsParam(
      name: name ?? this.name,
      timeline: timeline ?? this.timeline,
      expectedResult: expectedResult ?? this.expectedResult,
      suggestion: suggestion ?? this.suggestion,
      managerReviewNote: managerReviewNote ?? this.managerReviewNote,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory CpSelfPlanIdsParam.fromJson(Map<String, dynamic> json) => _$CpSelfPlanIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpSelfPlanIdsParamToJson(this);
}
