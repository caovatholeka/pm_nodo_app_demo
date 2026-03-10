import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/birthdays_entity.dart';

part 'birthdays_this_month_entity.g.dart';

@JsonSerializable()
class BirthdaysThisMonthEntity {
  @JsonKey()
  final String? month;

  @JsonKey()
  final List<BirthdaysEntity>? birthdays;

  BirthdaysThisMonthEntity({
    required this.month,
    required this.birthdays,
  });

  factory BirthdaysThisMonthEntity.fromJson(Map<String, dynamic> json) => _$BirthdaysThisMonthEntityFromJson(json);

  Map<String, dynamic> toJson() => _$BirthdaysThisMonthEntityToJson(this);
}