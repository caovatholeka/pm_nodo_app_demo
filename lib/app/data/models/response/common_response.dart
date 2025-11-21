import 'package:json_annotation/json_annotation.dart';

part 'common_response.g.dart';

@JsonSerializable()
class CommonResponse {
  final String? status;
  final String? message;
  final int? code;
  final bool? error;
  final int? total;
  final int? limit;
  final int? offset;
  final int? page;
  final int? total_pages;

  @JsonKey(name: "total_unread")
  final int? totalUnread;

  final dynamic data;
  final dynamic optional;


  CommonResponse({this.status, this.message, this.data, this.optional,
    this.code,this.error,
    this.total,
    this.page,
    this.total_pages,
    this.limit,
    this.offset,
    this.totalUnread
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) =>
      _$CommonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommonResponseToJson(this);
}