import 'package:json_annotation/json_annotation.dart';

part 'justification_entity.g.dart';

@JsonSerializable()
class JustificationEntity {
  final String code;
  final String date;
  final String type;
  final String creator;
  final String status;
  final int statusId;

  JustificationEntity({
    required this.code,
    required this.date,
    required this.type,
    required this.creator,
    required this.status,
    required this.statusId,
  });

  factory JustificationEntity.fromJson(Map<String, dynamic> json) =>
      _$JustificationEntityFromJson(json);

  Map<String, dynamic> toJson() => _$JustificationEntityToJson(this);
}
