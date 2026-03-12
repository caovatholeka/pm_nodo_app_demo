import 'package:json_annotation/json_annotation.dart';

part 'send_suggestion_param.g.dart';

@JsonSerializable()
class SendSuggestionParam {
  @JsonKey()
  final String? month;

  @JsonKey()
  final String? message;

  SendSuggestionParam({
    this.month,
    this.message,
  });

  factory SendSuggestionParam.fromJson(Map<String, dynamic> json) => _$SendSuggestionParamFromJson(json);

  Map<String, dynamic> toJson() => _$SendSuggestionParamToJson(this);
}
