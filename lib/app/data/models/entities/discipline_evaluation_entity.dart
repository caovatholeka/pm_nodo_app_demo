import 'package:json_annotation/json_annotation.dart';

part 'discipline_evaluation_entity.g.dart';

@JsonSerializable()
class DisciplineEvaluationEntity {
  @JsonKey()
  final String? month;

  @JsonKey(name: 'on_time_percent')
  final int? onTimePercent;

  @JsonKey(name: 'absent_count')
  final int? absentCount;

  @JsonKey(name: 'late_early_count')
  final int? lateEarlyCount;

  DisciplineEvaluationEntity({
    required this.month,
    required this.onTimePercent,
    required this.absentCount,
    required this.lateEarlyCount,
  });


  factory DisciplineEvaluationEntity.fromJson(Map<String, dynamic> json) => _$DisciplineEvaluationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DisciplineEvaluationEntityToJson(this);
  
}