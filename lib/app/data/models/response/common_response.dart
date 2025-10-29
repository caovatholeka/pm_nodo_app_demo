import 'package:json_annotation/json_annotation.dart';

part 'common_response.g.dart';

@JsonSerializable()
class CommonResponse {
  final String? status;
  final String? message;
  final int? code;
  final bool? error;
  final dynamic data;
  final dynamic optional;

  CommonResponse({this.status, this.message, this.data, this.optional,
    this.code,this.error
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) =>
      _$CommonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommonResponseToJson(this);
}