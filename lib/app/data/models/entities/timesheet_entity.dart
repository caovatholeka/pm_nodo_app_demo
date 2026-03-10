import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/items_entity.dart';

part 'timesheet_entity.g.dart';

@JsonSerializable()
class TimesheetEntity {

  @JsonKey()
  final String month;

  @JsonKey()
  final List<ItemsEntity> items;

  TimesheetEntity({
    required this.month,
    required this.items,
  });

    factory TimesheetEntity.fromJson(Map<String, dynamic> json) =>
        _$TimesheetEntityFromJson(json);

    Map<String, dynamic> toJson() => _$TimesheetEntityToJson(this);

}
