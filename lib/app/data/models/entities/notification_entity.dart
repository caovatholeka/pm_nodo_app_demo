import 'package:json_annotation/json_annotation.dart';

part 'notification_entity.g.dart';

@JsonSerializable()
class NotificationEntity {
  @JsonKey()
  int? id;
  
  @JsonKey()
  String? name;

  @JsonKey()
  String? title;

  @JsonKey()
  String? content;

  @JsonKey()
  String? link;

  @JsonKey(name: "is_seen")
  bool? isSeen;

  @JsonKey(name:"create_date")
  String? createDate;

  @JsonKey(name:"user_id")
  int? userID;

  @JsonKey(name: "user_name")
  String? username;

  NotificationEntity({
    this.id,
    this.name,
    this.title,
    this.content,
    this.link,
    this.isSeen,
    this.createDate,
    this.userID,
    this.username
  });


  NotificationEntity copyWith({
    int? id,
    String? name,
    String? title,
    String? content,
    String? link,
    bool? isSeen,
    String? createDate,
    int? userID,
    String? username
  }){
    return NotificationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      content: content ?? this.content,
      link: link ?? this.link,
      isSeen: isSeen ?? this.isSeen,
      createDate: createDate ?? this.createDate,
      userID: userID ?? this.userID,
      username: username ?? this.username,
    );
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>  _$NotificationEntityFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationEntityToJson(this);

}