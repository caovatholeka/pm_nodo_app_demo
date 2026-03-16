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
  dynamic volume;

  @JsonKey()
  dynamic quality;

  @JsonKey()
  dynamic progress;

  @JsonKey()
  String? note;

  @JsonKey(name: "parent_volume")
  dynamic parentVolume;

  @JsonKey(name: "parent_quality")
  dynamic parentQuality;

  @JsonKey(name: "parent_progress")
  dynamic parentProgress;

  @JsonKey(name: "parent_note")
  String? parentNote;

  @JsonKey()
  dynamic weight;

  @JsonKey(name: "total_score")
  dynamic totalScore;

  @JsonKey(name: "parent_total_score")
  dynamic parentTotalScore;


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
    this.parentNote,
    this.weight,
    this.totalScore,
    this.parentTotalScore,
  });

  TaskLineIdEntity copyWith({
    int? id,
    String? name,
    String? jiraKey,
    int? rate,
    dynamic volume,
    dynamic quality,
    dynamic progress,
    String? note,
    dynamic parentVolume,
    dynamic parentQuality,
    dynamic parentProgress,
    String? parentNote,
    dynamic weight,
    dynamic totalScore,
    dynamic parentTotalScore,
  }) {
    return TaskLineIdEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        jiraKey: jiraKey ?? this.jiraKey,
        rate: rate ?? this.rate,
        volume: volume ?? this.volume,
        quality: quality ?? this.quality,
        progress: progress ?? this.progress,
        note: note ?? this.note,
        parentVolume: parentVolume ?? this.parentVolume,
        parentQuality: parentQuality ?? this.parentQuality,
        parentProgress: parentProgress ?? this.parentProgress,
        parentNote: parentNote ?? this.parentNote,
        weight: weight ?? this.weight,
        totalScore: totalScore ?? this.totalScore,
        parentTotalScore: parentTotalScore ?? this.parentTotalScore,
    );
  }

  factory TaskLineIdEntity.fromJson(Map<String, dynamic> json) =>
      _$TaskLineIdEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLineIdEntityToJson(this);
}
