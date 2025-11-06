import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';

part 'on_leave_response.g.dart';

@JsonSerializable()
class OnLeaveResponse {
  @JsonKey()
  String? message;

  @JsonKey()
  int? id;

  @JsonKey(name:"number_of_days")
  double? numberOfDays;

  @JsonKey(name:"line_count")
  int? lineCount;

  @JsonKey()
  List<LeaveDayEntity>? lines;

  OnLeaveResponse({
    this.message,
    this.id,
    this.numberOfDays,
    this.lineCount,
    this.lines
  });


  factory OnLeaveResponse.fromJson(Map<String, dynamic> json) =>
      _$OnLeaveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OnLeaveResponseToJson(this);

}