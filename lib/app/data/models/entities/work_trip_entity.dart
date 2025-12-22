import 'package:json_annotation/json_annotation.dart';
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
  String? note;

  @JsonKey()
  String? state;

  @JsonKey(name: "reason_cancel")
  String? reasonCancel;

  @JsonKey(name: "employee_count")
  int? employeeCount;

  @JsonKey()
  WorkFlowStageEntity? stage;

  WorkTripEntity({
    this.id,
    this.name,
    this.fromDate,
    this.toDate,
    this.note,
    this.state,
    this.employeeCount,
    this.reasonCancel,
    this.stage
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
    WorkFlowStageEntity? stage
  }) {
    return WorkTripEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      state: state ?? this.state,
      reasonCancel: reasonCancel ?? this.reasonCancel,
      employeeCount: employeeCount ?? this.employeeCount,
      stage: stage ?? this.stage
    );
  }

  factory WorkTripEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkTripEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkTripEntityToJson(this);
}