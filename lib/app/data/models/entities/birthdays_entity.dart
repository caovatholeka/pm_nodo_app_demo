import 'package:json_annotation/json_annotation.dart';

part 'birthdays_entity.g.dart';

@JsonSerializable() 
class BirthdaysEntity {
  @JsonKey(name:'employee_id')
  final int? employeeId;

  @JsonKey()
  final String? name;

  @JsonKey()
  final String? avatar;

  @JsonKey(name:'birth_date')
  final String? birthDate;

  BirthdaysEntity({
    required this.employeeId,
    required this.name,
    required this.avatar,
    required this.birthDate,
  });

  factory BirthdaysEntity.fromJson(Map<String, dynamic> json) => _$BirthdaysEntityFromJson(json);

  Map<String, dynamic> toJson() => _$BirthdaysEntityToJson(this);

}