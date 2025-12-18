import 'package:json_annotation/json_annotation.dart';
import 'package:pm_app/app/data/models/param/exception_line_param.dart';

part 'create_justification_param.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateJustificationParam {
  @JsonKey()
  String? date;

  @JsonKey(name: "reason_type")
  String? reasonType;

  @JsonKey()
  String? note;

  @JsonKey(name: "exception_lines")
  List<ExceptionLineParam>? exceptionLines;

  CreateJustificationParam({
    this.date,
    this.reasonType,
    this.note,
    this.exceptionLines,
  });

  CreateJustificationParam copyWith({
    String? date,
    String? reasonType,
    String? note,
    List<ExceptionLineParam>? exceptionLines,
  }) {
    return CreateJustificationParam(
      date: date ?? this.date,
      reasonType: reasonType ?? this.reasonType,
      note: note ?? this.note,
      exceptionLines: exceptionLines ?? this.exceptionLines,
    );
  }

  factory CreateJustificationParam.fromJson(Map<String, dynamic> json) =>
      _$CreateJustificationParamFromJson(json);

  Map<String, dynamic> toJson() {
    final map = _$CreateJustificationParamToJson(this);
    map.removeWhere((key, value) =>
        value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty));
    return map;
  }
}
