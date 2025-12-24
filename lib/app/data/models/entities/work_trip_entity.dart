import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';
import 'package:pm_app/app/data/models/entities/work_flow_stage_entity.dart';

part 'work_trip_entity.g.dart';

@JsonSerializable()
class WorkTripEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey(name: "from_date")
  String? fromDate;

  @JsonKey(name: "to_date")
  String? toDate;

  @JsonKey()
  String? address;

  @JsonKey(name: "total_people")
  int? totalPeople;

  @JsonKey(name: "number_of_days")
  double? numberOfDays;

  @JsonKey(name:"employee_id")
  int? employeeId;

  @JsonKey(name:"create_uid")
  int? createUid;

  @JsonKey(name:"employee_name")
  String? employeeName;

  @JsonKey()
  String? note;

  @JsonKey()
  String? state;

  @JsonKey(name: "reason_cancel")
  String? reasonCancel;

  @JsonKey(name: "employee_count")
  int? employeeCount;

  @JsonKey()
  WorkFlowStageEntity? stage;

  @JsonKey()
  List<UserEntity>? employees;

  @JsonKey()
  List<ScheduleEntity>? schedules;

  WorkTripEntity({
    this.id,
    this.name,
    this.fromDate,
    this.toDate,
    this.note,
    this.state,
    this.address,
    this.totalPeople,
    this.numberOfDays,
    this.employees,
    this.schedules,
    this.employeeCount,
    this.reasonCancel,
    this.stage,
    this.employeeId,
    this.createUid,
    this.employeeName
  });

  WorkTripEntity copyWith({
    int? id,
    String? name,
    String? fromDate,
    String? toDate,
    String? note,
    String? state,
    String? reasonCancel,
    int? employeeCount,
    String? address,
    int? totalPeople,
    double? numberOfDays,
    WorkFlowStageEntity? stage,
    int? employeeId,
    int? createUid,
    String? employeeName,
    List<UserEntity>? employees,
    List<ScheduleEntity>? schedules,
  }) {
    return WorkTripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      address: address ?? this.address,
      totalPeople: totalPeople ?? this.totalPeople,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      state: state ?? this.state,
      reasonCancel: reasonCancel ?? this.reasonCancel,
      employeeCount: employeeCount ?? this.employeeCount,
      stage: stage ?? this.stage,
      employeeId: employeeId ?? this.employeeId,
      createUid: createUid ?? this.createUid,
      employeeName: employeeName ?? this.employeeName,
      employees: employees ?? this.employees,
      schedules: schedules ?? this.schedules
    );
  }

  factory WorkTripEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkTripEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkTripEntityToJson(this);
}