import 'package:json_annotation/json_annotation.dart';

part 'work_shift_entity.g.dart';
@JsonSerializable()
class WorkShiftEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;

  WorkShiftEntity({
    this.id,
    this.name,
  });

  WorkShiftEntity copyWith({
    int? id,
    String? name,
  }) {
    return WorkShiftEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory WorkShiftEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkShiftEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkShiftEntityToJson(this);
}