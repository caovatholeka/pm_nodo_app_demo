import 'package:json_annotation/json_annotation.dart';

part 'on_leave_entity.g.dart';

@JsonSerializable()
class OnLeaveEntity {
  @JsonKey()
  int? id;

  @JsonKey()
  int? status;

  OnLeaveEntity({
    this.id,
    this.status,});

  OnLeaveEntity copyWith({
    int? id,
    int? status,

  }) {
    return OnLeaveEntity(
      id: id ?? this.id,
      status: status ?? this.status,

    );
  }

  factory OnLeaveEntity.fromJson(Map<String, dynamic> json) => _$OnLeaveEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OnLeaveEntityToJson(this);
}