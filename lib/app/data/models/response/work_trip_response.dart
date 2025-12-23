import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';

import '../entities/work_flow_stage_entity.dart';

part 'work_trip_response.g.dart';

@JsonSerializable()
class WorkTripResponse {
  @JsonKey()
  String? message;

  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey(name:"from_date")
  String? fromDate;

  @JsonKey(name:"to_date")
  String? toDate;

  @JsonKey(name:"number_of_days")
  double? numberOfDays;

  @JsonKey()
  String? state;

  @JsonKey()
  WorkFlowStageEntity? stage;

  @JsonKey()
  List<UserEntity>? employees;

  @JsonKey()
  List<ScheduleEntity>? schedules;

  WorkTripResponse({
    this.message,
    this.id,
    this.name,
    this.fromDate,
    this.toDate,
    this.state,
    this.stage,
    this.numberOfDays,
    this.employees,
    this.schedules,
  });


  factory WorkTripResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkTripResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WorkTripResponseToJson(this);

}