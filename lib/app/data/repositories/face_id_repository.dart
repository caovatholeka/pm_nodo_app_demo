import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pm_app/app/core/network/api_client_face_id.dart';
import '../models/entities/face_search_response_entity.dart';
import 'package:path/path.dart' as p;

abstract class FaceIdRepository {
  Future<FaceSearchResponseEntity> searchEmployeeFace(File file);
}

class FaceIdRepositoryImpl extends FaceIdRepository {
  late ApiClientFaceId _apiClient;

  FaceIdRepositoryImpl(ApiClientFaceId client) {
    _apiClient = client;
  }

  @override
  Future<FaceSearchResponseEntity> searchEmployeeFace(File file) async {

    FormData formData = FormData.fromMap({
      'query_image': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
      'top_k': 1,
      'similarity_threshold': 0.4,
    });

    return await _apiClient.searchFaceEmployee(formData);
  }
}