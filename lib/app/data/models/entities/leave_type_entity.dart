import 'package:json_annotation/json_annotation.dart';

part 'leave_type_entity.g.dart';

@JsonSerializable()
class LeaveTypeEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  String? name;


  LeaveTypeEntity({
    this.id,
    this.name
  });

  LeaveTypeEntity copyWith({
    int? id,
    String? name
  }){
    return LeaveTypeEntity(
      id: id ?? this.id,
      name: name ?? this.name
    );
  }

  factory LeaveTypeEntity.fromJson(Map<String, dynamic> json) => _$LeaveTypeEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypeEntityToJson(this);
}