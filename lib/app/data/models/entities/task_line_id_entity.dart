import 'package:json_annotation/json_annotation.dart';

part 'task_line_id_entity.g.dart';
@JsonSerializable()
class TaskLineIdEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  @JsonKey(name: "jira_key")
  String? jiraKey;

  @JsonKey()
  int? rate;

  @JsonKey()
  String? volume;

  @JsonKey()
  String? quality;

  @JsonKey()
  String? progress;

  @JsonKey()
  String? note;

  @JsonKey(name: "parent_volume")
  bool? parentVolume;

  @JsonKey(name: "parent_quality")
  bool? parentQuality;

  @JsonKey(name: "parent_progress")
  bool? parentProgress;

  @JsonKey(name: "parent_note")
  String? parentNote;


  TaskLineIdEntity({
    this.id,
    this.name,
    this.jiraKey,
    this.rate,
    this.volume,
    this.quality,
    this.progress,
    this.note,
    this.parentVolume,
    this.parentQuality,
    this.parentProgress,
    this.parentNote
  });

  TaskLineIdEntity copyWith({
    int? id,
    String? name,
    String? jiraKey,
    int? rate,
    String? volume,
    String? quality,
    String? progress,
    String? note,
    bool? parentVolume,
    bool? parentQuality,
    bool? parentProgress,
    String? parentNote
  }) {
    return TaskLineIdEntity(
        id: id ?? this.id,
        name: name ?? this.note,
        jiraKey: jiraKey ?? this.jiraKey,
        rate: rate ?? this.rate,
        volume: volume ?? this.volume,
        quality: quality ?? this.quality,
        progress: progress ?? this.progress,
        note: note ?? this.note,
        parentVolume: parentVolume ?? this.parentVolume,
        parentQuality: parentQuality ?? this.parentQuality,
        parentProgress: parentProgress ?? this.parentProgress,
        parentNote: parentNote ?? this.parentNote
    );
  }

  factory TaskLineIdEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskLineIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLineIdEntityToJson(this);
}