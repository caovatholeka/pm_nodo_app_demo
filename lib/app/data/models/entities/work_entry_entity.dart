import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/work_entry_shift_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entry_type_entity.dart';

part 'work_entry_entity.g.dart';

@JsonSerializable()
class WorkEntryEntity {
  @JsonKey()
  final int? id;

  @JsonKey()
  final String? date;

  @JsonKey(name: "date_start")
  final String? dateStart;

  @JsonKey(name: "date_stop")
  final String? dateStop;

  @JsonKey(name: "work_entry_type")
  final WorkEntryTypeEntity? workEntryType;

  @JsonKey(name: "work_entry_label")
  final String? workEntryLabel;

  @JsonKey()
  final String? display;

  @JsonKey()
  final String? state;

  @JsonKey()
  final WorkEntryShiftEntity? shift;

  @JsonKey(name: "work_time")
  final double? workTime;

  @JsonKey(name: "late_time")
  final double? lateTime;

  @JsonKey(name: "early_time")
  final double? earlyTime;

  @JsonKey(name: "date_start_employee_commit")
  final double? dateStartCommit;

  @JsonKey(name: "date_stop_employee_commit")
  final double? dateStopCommit;

  @JsonKey()
  final dynamic note; 
  WorkEntryEntity({
    this.id,
    this.date,
    this.dateStart,
    this.dateStop,
    this.workEntryType,
    this.workEntryLabel,
    this.display,
    this.state,
    this.shift,
    this.workTime,
    this.lateTime,
    this.earlyTime,
    this.dateStartCommit,
    this.dateStopCommit,
    this.note,
  });

  factory WorkEntryEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkEntryEntityToJson(this);
}
