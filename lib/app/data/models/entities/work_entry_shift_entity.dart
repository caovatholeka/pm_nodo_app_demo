import 'package:json_annotation/json_annotation.dart';

part 'work_entry_shift_entity.g.dart';

@JsonSerializable()
class WorkEntryShiftEntity {
  @JsonKey()
  final int? id;

  @JsonKey()
  final String? name;

  WorkEntryShiftEntity({
    this.id,
    this.name,
  });

  factory WorkEntryShiftEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntryShiftEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkEntryShiftEntityToJson(this);
}
