import 'package:json_annotation/json_annotation.dart';

part 'department_entity.g.dart';

@JsonSerializable()
class DepartmentEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  DepartmentEntity({
    this.id,
    this.code,
    this.name,
  });

  DepartmentEntity copyWith({
    int? id,
    String? code,
    String? name,
  }) {
    return DepartmentEntity(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
    );
  }

  factory DepartmentEntity.fromJson(Map<String, dynamic> json) => _$DepartmentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentEntityToJson(this);
}