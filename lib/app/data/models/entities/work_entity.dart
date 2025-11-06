import 'package:json_annotation/json_annotation.dart';

part 'work_entity.g.dart';

@JsonSerializable()
class WorkEntity {
  @JsonKey()
  String? display;

  @JsonKey(name: 'work_entry_label')
  String? workEntryLabel;

  @JsonKey()
  double? duration;

  @JsonKey(name: "name_stage")
  String? nameStage;

  @JsonKey(name: "date_start")
  String? dateStart;

  @JsonKey(name: "date_stop")
  String? dateStop;

  WorkEntity({
    this.display,
    this.workEntryLabel,
    this.duration,
    this.nameStage,
    this.dateStart,
    this.dateStop,
  });

  WorkEntity copyWith({
    String? display,
    String? workEntryLabel,
    double? duration,
    String? nameStage,
    String? dateStart,
    String? dateStop,
  }) {
    return WorkEntity(
      display: display ?? this.display,
      workEntryLabel: workEntryLabel ?? this.workEntryLabel,
      duration: duration ?? this.duration,
      nameStage: nameStage ?? this.nameStage,
      dateStart: dateStart ?? this.dateStart,
      dateStop: dateStop ?? this.dateStop,
    );
  }

  factory WorkEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkEntityToJson(this);
}