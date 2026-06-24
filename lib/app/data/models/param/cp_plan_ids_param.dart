import 'package:json_annotation/json_annotation.dart';

part 'cp_plan_ids_param.g.dart';

@JsonSerializable()
class CpPlanIdsParam {
  @JsonKey()
  String? name;

  @JsonKey()
  String? timeline;

  @JsonKey(name: "expected_result")
  String? expectedResult;

  @JsonKey()
  String? suggestion;

  @JsonKey(name: "manager_review_note")
  String? managerReviewNote;

  @JsonKey(name: "is_checked")
  bool? isChecked;

  CpPlanIdsParam({
    this.name,
    this.timeline,
    this.expectedResult,
    this.suggestion,
    this.managerReviewNote,
    this.isChecked,
  });

  CpPlanIdsParam copyWith({
    String? name,
    String? timeline,
    String? expectedResult,
    String? suggestion,
    String? managerReviewNote,
    bool? isChecked,
  }) {
    return CpPlanIdsParam(
      name: name ?? this.name,
      timeline: timeline ?? this.timeline,
      expectedResult: expectedResult ?? this.expectedResult,
      suggestion: suggestion ?? this.suggestion,
      managerReviewNote: managerReviewNote ?? this.managerReviewNote,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  factory CpPlanIdsParam.fromJson(Map<String, dynamic> json) => _$CpPlanIdsParamFromJson(json);
  Map<String, dynamic> toJson() => _$CpPlanIdsParamToJson(this);
}