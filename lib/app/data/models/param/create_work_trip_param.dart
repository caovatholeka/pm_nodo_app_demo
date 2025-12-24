import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';

part 'create_work_trip_param.g.dart';

@JsonSerializable()
class CreateWorkTripParam {
  @JsonKey(name: "employee_ids")
  List<int>? employeeIds;

  @JsonKey()
  String? note;

  @JsonKey()
  String? address;

  @JsonKey(name: "need_ticket")
  bool? needTicket;

  @JsonKey(name: "need_room")
  bool? needRoom;

  @JsonKey()
  List<ScheduleEntity>? schedules;

  CreateWorkTripParam({
    this.employeeIds,
    this.note,
    this.address,
    this.needTicket,
    this.needRoom,
    this.schedules,
  });

  CreateWorkTripParam copyWith({
    List<int>? employeeIds,
    String? note,
    String? address,
    bool? needTicket,
    bool? needRoom,
    List<ScheduleEntity>? schedules,
  }) {
    return CreateWorkTripParam(
      employeeIds: employeeIds ?? this.employeeIds,
      note: note ?? this.note,
      address: address ?? this.address,
      needTicket: needTicket ?? this.needTicket,
      needRoom: needRoom ?? this.needRoom,
      schedules: schedules ?? this.schedules,
    );
  }

  factory CreateWorkTripParam.fromJson(Map<String, dynamic> json) => _$CreateWorkTripParamFromJson(json);

  Map<String, dynamic> toJson(){
    final map = _$CreateWorkTripParamToJson(this);
    map.removeWhere((key, value) =>
    value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty));
    return map;
  }
}