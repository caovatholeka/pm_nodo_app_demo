import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/work_entry_type_entity.dart';
import 'package:pm_app/app/data/models/entities/work_shift_entity.dart';

part 'work_entity.g.dart';

@JsonSerializable()
class WorkEntity {

  @JsonKey()
  int? id;

  @JsonKey()
  String? display;

  @JsonKey(name: 'work_entry_label')
  String? workEntryLabel;

  @JsonKey()
  double? duration;

  @JsonKey(name: "name_stage")
  String? nameStage;

  @JsonKey()
  String? date;

  @JsonKey(name: "date_start")
  String? dateStart;

  @JsonKey(name: "date_stop")
  String? dateStop;

  @JsonKey(name: "work_entry_type")
  WorkEntryTypeEntity? workEntryType;

  @JsonKey()
  String? state;

  @JsonKey()
  WorkShiftEntity? shift;

  @JsonKey(name: "work_time")
  double? workTime;

  @JsonKey(name: "late_time")
  double? lateTime;

  @JsonKey(name: "early_time")
  double? earlyTime;


  @JsonKey(name: "total_invalid_time")
  double? totalInvalidTime;

  @JsonKey(name: "date_start_employee_commit")
  double? dateStartEmployeeCommit;

  @JsonKey(name: "date_stop_employee_commit")
  double? dateStopEmployeeCommit;

  @JsonKey()
  String? note;

  @JsonKey(name: "remain_day")
  double? remainDay;

  @JsonKey(name: "second_day_leave")
  double? secondDayLeave;

  WorkEntity({
    this.id,
    this.display,
    this.workEntryLabel,
    this.duration,
    this.nameStage,
    this.date,
    this.dateStart,
    this.dateStop,
    this.workEntryType,
    this.state,
    this.shift,
    this.workTime,
    this.lateTime,
    this.earlyTime,
    this.totalInvalidTime,
    this.dateStartEmployeeCommit,
    this.dateStopEmployeeCommit,
    this.note,
    this.remainDay,
    this.secondDayLeave
  });

  WorkEntity copyWith({
    int? id,
    String? display,
    String? workEntryLabel,
    double? duration,
    String? nameStage,
    String? date,
    String? dateStart,
    String? dateStop,
    WorkEntryTypeEntity? workEntryType,
    String? state,
    WorkShiftEntity? shift,
    double? workTime,
    double? lateTime,
    double? earlyTime,
    double? totalInvalidTime,
    double? dateStartEmployeeCommit,
    double? dateStopEmployeeCommit,
    String? note,
    double? remainDay,
    double? secondDayLeave,
  }) {
    return WorkEntity(
      id: id ?? this.id,
      display: display ?? this.display,
      workEntryLabel: workEntryLabel ?? this.workEntryLabel,
      duration: duration ?? this.duration,
      nameStage: nameStage ?? this.nameStage,
      date: date ?? this.date,
      dateStart: dateStart ?? this.dateStart,
      dateStop: dateStop ?? this.dateStop,
      workEntryType: workEntryType ?? this.workEntryType,
      state: state ?? this.state,
      shift: shift ?? this.shift,
      workTime: workTime ?? this.workTime,
      lateTime: lateTime ?? this.lateTime,
      earlyTime: earlyTime ?? this.earlyTime,
      totalInvalidTime: totalInvalidTime ?? this.totalInvalidTime,
      dateStartEmployeeCommit: dateStartEmployeeCommit ?? this.dateStartEmployeeCommit,
      dateStopEmployeeCommit: dateStopEmployeeCommit ?? this.dateStopEmployeeCommit,
      note: note ?? this.note,
      remainDay: remainDay ?? this.remainDay,
      secondDayLeave: secondDayLeave ?? this.secondDayLeave
    );
  }

  factory WorkEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkEntityToJson(this);
}