import 'package:json_annotation/json_annotation.dart';

part 'token_entity.g.dart';

@JsonSerializable()
class TokenEntity {
  @JsonKey(name: 'access_token')
  String? accessToken;

  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'refresh_token')
  String? refreshToken;

  @JsonKey(name: 'expires_in')
  int? expiresIn;

  @JsonKey(name: 'refresh_token_expires_in')
  int? refreshTokenExpiresIn;

  @JsonKey(name: 'uid')
  int? uid;

  @JsonKey(name: 'partner_id')
  int? partnerId;

  TokenEntity({
    this.accessToken,
    this.id,
    this.refreshToken,
    this.expiresIn,
    this.refreshTokenExpiresIn,
    this.uid,
    this.partnerId,
  });

  TokenEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? id,
    int? expiresIn,
    int? refreshTokenExpiresIn,
    int? uid,
    int? partnerId,
  }) {
    return TokenEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      id: id ?? this.id,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshTokenExpiresIn: refreshTokenExpiresIn ?? this.refreshTokenExpiresIn,
      uid: uid ?? this.uid,
      partnerId: partnerId ?? this.partnerId,
    );
  }

  factory TokenEntity.fromJson(Map<String, dynamic> json) =>
      _$TokenEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TokenEntityToJson(this);
}
