import 'package:json_annotation/json_annotation.dart';

part 'general_error_entity.g.dart';

@JsonSerializable()
class GeneralErrorCode {
  @JsonKey()
  Errors? errors;

  GeneralErrorCode({this.errors});

  factory GeneralErrorCode.fromJson(Map<String, dynamic> json) => _$GeneralErrorCodeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralErrorCodeToJson(this);
}

@JsonSerializable()
class Errors {
  String? message;

  Errors({this.message});

  factory Errors.fromJson(Map<String, dynamic> json) {
    var message = "";
    json.forEach((key, value) {
      if(key.toLowerCase().contains("error")) {
        message = value;
        return;
      }
    });
    return Errors(message: message);
  }
}