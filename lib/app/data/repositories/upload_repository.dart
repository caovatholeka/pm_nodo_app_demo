import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/file_entity.dart';

abstract class UploadRepository {
  Future<List<FileEntity>> uploadFiles(File file);
}

class UploadRepositoryImpl extends UploadRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<List<FileEntity>> uploadFiles(File file) async {
    FormData formData = FormData.fromMap({
      "files": await MultipartFile.fromFile(file.path),
    });
    return await _apiClient.uploadFiles(formData);
  }
}

