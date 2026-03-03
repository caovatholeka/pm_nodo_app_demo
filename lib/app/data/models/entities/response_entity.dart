import 'package:json_annotation/json_annotation.dart';

part 'response_entity.g.dart';

@JsonSerializable()
class ResponseEntity {
  @JsonKey()
  String? code;

  @JsonKey()
  String? name;

  @JsonKey(name: "rate_point")
  bool? ratePoint;

  @JsonKey(name: "parent_rate_point")
  bool? parentRatePoint;

  @JsonKey()
  String? note;

  @JsonKey(name: "parent_note")
  String? parentNote;

  ResponseEntity({
    this.code,
    this.name,
    this.ratePoint,
    this.parentRatePoint,
    this.note,
    this.parentNote,
  });

  ResponseEntity copyWith({
    String? code,
    String? name,
    bool? ratePoint,
    bool? parentRatePoint,
    String? note,
    String? parentNote,
  }) {
    return ResponseEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      ratePoint: ratePoint ?? this.ratePoint,
      parentRatePoint: parentRatePoint ?? this.parentRatePoint,
      note: note ?? this.note,
      parentNote: parentNote ?? this.parentNote,
    );
  }

  factory ResponseEntity.fromJson(Map<String, dynamic> json) =>
      _$ResponseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseEntityToJson(this);
}
