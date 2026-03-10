import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/weeks_entity.dart';

part 'discipline_evaluation_detail_entity.g.dart';

@JsonSerializable()
class DisciplineEvaluationDetailEntity {
  @JsonKey()
  final String? month;

  @JsonKey()
  final List<WeeksEntity>? weeks;

  @JsonKey(name: 'on_time_percent')
  final int? onTimePercent;

  @JsonKey(name: 'absent_count')
  final int? absentCount;

  @JsonKey(name: 'late_early_count')
  final int? lateEarlyCount;


  DisciplineEvaluationDetailEntity({
    required this.month,
    required this.weeks,
    required this.onTimePercent,
    required this.absentCount,
    required this.lateEarlyCount
  });

    factory DisciplineEvaluationDetailEntity.fromJson(Map<String, dynamic> json) => _$DisciplineEvaluationDetailEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DisciplineEvaluationDetailEntityToJson(this);
}