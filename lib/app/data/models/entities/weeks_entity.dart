import 'package:json_annotation/json_annotation.dart';

part 'weeks_entity.g.dart';

@JsonSerializable()
class WeeksEntity {
  @JsonKey()
  final String? month;

  @JsonKey(name: 'week_label')
  final String? weekLabel;

  @JsonKey(name: 'early_late_count')
  final int? earlyLateCount;

  @JsonKey(name: 'leave_count')
  final int? leaveCount;

  WeeksEntity({
     this.month,
     this.weekLabel,
     this.earlyLateCount,
    this.leaveCount,
  });

  factory WeeksEntity.fromJson(Map<String, dynamic> json) => _$WeeksEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WeeksEntityToJson(this);

}