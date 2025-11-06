import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';

part 'attendance_entity.g.dart';

@JsonSerializable()
class AttendanceEntity {
  @JsonKey()
  String? date;

  @JsonKey(name: "work_entries")
  List<WorkEntity>? workEntries;

  AttendanceEntity({
    this.date,
    this.workEntries
  });

  AttendanceEntity copyWith({
    String? date,
    List<WorkEntity>? workEntries,
  }) {
    return AttendanceEntity(
      date: date ?? this.date,
      workEntries: workEntries ?? this.workEntries,
    );
  }

  factory AttendanceEntity.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceEntityToJson(this);
}