import 'package:json_annotation/json_annotation.dart';

part 'work_entry_type_entity.g.dart';
@JsonSerializable()
class WorkEntryTypeEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  WorkEntryTypeEntity({
    this.id,
    this.code,
    this.name,
  });

  WorkEntryTypeEntity copyWith({
    int? id,
    String? code,
    String? name,
  }) {
    return WorkEntryTypeEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  factory WorkEntryTypeEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkEntryTypeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$WorkEntryTypeEntityToJson(this);
}