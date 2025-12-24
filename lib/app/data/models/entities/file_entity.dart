import 'package:json_annotation/json_annotation.dart';

part 'file_entity.g.dart';

@JsonSerializable()
class FileEntity {
  @JsonKey(name:'originalName')
  String? name;
  @JsonKey()
  String? filename;
  @JsonKey()
  String? url;
  @JsonKey()
  String? absoluteUrl;
  @JsonKey()
  String? uploadName;

  FileEntity({this.name, this.filename, this.url, this.absoluteUrl, this.uploadName});

  FileEntity copyWith({
    String? name,
    String? filename,
    String? url,
    String? absoluteUrl,
    String? uploadName
  }) {
    return FileEntity(
      name: name ?? this.name,
      filename: filename ?? this.filename,
      url: url ?? this.url,
      absoluteUrl: absoluteUrl ?? this.absoluteUrl,
      uploadName: uploadName ?? this.uploadName
    );
  }

  factory FileEntity.fromJson(Map<String, dynamic> json) => _$FileEntityFromJson(json);

  Map<String, dynamic> toJson() => _$FileEntityToJson(this);

  // factory FileEntity.fromJson(Map<String, dynamic> json) => FileEntity(
  //   name: json['originalName'] is String ? json['originalName'] as String : null,
  //   filename: json['name'] is String ? json['name'] as String : null,
  //   url: json['url'] is String ? json['url'] as String : null,
  //   absoluteUrl: json['absoluteUrl'] is String ? json['absoluteUrl'] as String : null,
  //   uploadName: json['uploadName'] is String ? json['uploadName'] as String : null,
  // );
  //
  // Map<String, dynamic> toJson() => {
  //   "name": name,
  //   "filename": name,
  //   "uploadName": uploadName,
  //   "absoluteUrl": absoluteUrl,
  //   "url": url,
  // };

}