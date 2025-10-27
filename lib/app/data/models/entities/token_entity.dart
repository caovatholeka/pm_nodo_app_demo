import 'package:json_annotation/json_annotation.dart';

part 'token_entity.g.dart';

@JsonSerializable()
class TokenEntity {
  @JsonKey()
  String? accessToken;

  @JsonKey()
  String? id;

  @JsonKey()
  String? refreshToken;

  @JsonKey()
  int? expiresIn;

  @JsonKey()
  int? refreshTokenExpiresIn;

  TokenEntity({
    this.accessToken,
    this.id,
    this.refreshToken,
    this.expiresIn,
    this.refreshTokenExpiresIn
  });

  TokenEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? id,
    int? expiresIn,
    int? refreshTokenExpiresIn
  }) {
    return TokenEntity(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        id: id ?? this.id,
        expiresIn: expiresIn ?? this.expiresIn,
        refreshTokenExpiresIn: refreshTokenExpiresIn ?? this.refreshTokenExpiresIn
    );
  }

  factory TokenEntity.fromJson(Map<String, dynamic> json) => _$TokenEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TokenEntityToJson(this);


}