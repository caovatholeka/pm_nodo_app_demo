import 'dart:io';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

import '../models/entities/file_entity.dart';

class AttachFile {
  String id;
  String? path;
  String? name;
  Asset? asset;
  File? file;
  String? urlPath;
  String? mime;
  FileEntity? fileUpload;

  // FileDeleteInfo fileDeleted;

  AttachFile({
    required this.id,
    this.path,
    this.name,
    this.asset,
    this.file,
    this.mime,
    this.urlPath,
    this.fileUpload,
    // this.fileDeleted
  });
}