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

  @JsonKey()
  int? uid;

  @JsonKey()
  int? partner_id;

  TokenEntity({
    this.accessToken,
    this.id,
    this.refreshToken,
    this.expiresIn,
    this.refreshTokenExpiresIn,
    this.uid,
    this.partner_id
  });

  TokenEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? id,
    int? expiresIn,
    int? refreshTokenExpiresIn,
    int? uid,
    int? partner_id
  }) {
    return TokenEntity(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        id: id ?? this.id,
        expiresIn: expiresIn ?? this.expiresIn,
        refreshTokenExpiresIn: refreshTokenExpiresIn ?? this.refreshTokenExpiresIn,
      uid: uid ?? this.uid,
      partner_id: partner_id ?? this.partner_id
    );
  }

  factory TokenEntity.fromJson(Map<String, dynamic> json) => _$TokenEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TokenEntityToJson(this);


}