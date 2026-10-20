import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../config/app_config.dart';
import '../../core/commons/global_data.dart';
import '../../core/logger/logger.dart';
import '../../core/network/api_util.dart';
import '../local/shared_prefs_helper.dart';
import '../models/entities/face_search_data_entity.dart';
import '../models/entities/face_search_response_entity.dart';
import '../models/entities/face_search_result_entity.dart';

abstract class FaceIdRepository {
  Future<FaceSearchResponseEntity> searchEmployeeFace(File file);
}

class FaceIdRepositoryImpl extends FaceIdRepository {
  Dio get _dio => ApiUtil.instance.uploadDio;

  @override
  Future<FaceSearchResponseEntity> searchEmployeeFace(File file) async {
    final formData = FormData.fromMap({
      'query_image': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
      'top_k': 1,
      'similarity_threshold': 0.4,
    });

    final base = AppConfig.baseFaceIdUrl.endsWith('/')
        ? AppConfig.baseFaceIdUrl
        : '${AppConfig.baseFaceIdUrl}/';
    final url = '${base}api/v1/faces/search-face';

    final token = GlobalData.instance.token ?? await SharedPrefsHelper.getToken();
    final accessToken = token?.accessToken;
    final headers = <String, dynamic>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
      headers['access-token'] = accessToken;
      headers['access_token'] = accessToken;
    }

    final response = await _dio.post<dynamic>(
      url,
      data: formData,
      options: Options(
        responseType: ResponseType.json,
        headers: headers,
      ),
    );

    logger.d('Face search response type: ${response.data.runtimeType}');
    logger.long('Face search response data: ${response.data}');

    return _parseFaceSearchResponse(response.data);
  }

  FaceSearchResponseEntity _parseFaceSearchResponse(dynamic rawData) {
    final data = _normalizeData(rawData);
    final payload = _asMap(data);
    final rawBody = _asNullableMap(payload['data']);

    final body = rawBody ?? payload;
    final rawResults = body['results'] ?? body['search_results'] ?? const [];

    final results =
        (rawResults is List)
            ? rawResults
                .map(_parseFaceSearchResult)
                .whereType<FaceSearchResultEntity>()
                .toList()
            : <FaceSearchResultEntity>[];

    final searchData = FaceSearchDataEntity(
      queryFilename: _asString(body['query_filename'] ?? body['query_image']),
      topK: _asInt(body['top_k']),
      similarityThreshold: _asDouble(body['similarity_threshold']),
      resultsCount: _asInt(body['results_count']) ?? results.length,
      searchResults: results,
    );

    return FaceSearchResponseEntity(
      success: _asBool(payload['success']),
      message: _asString(payload['message']),
      searchData: searchData,
    );
  }

  FaceSearchResultEntity? _parseFaceSearchResult(dynamic item) {
    final map = _asNullableMap(item);
    if (map == null) {
      return null;
    }

    return FaceSearchResultEntity(
      employeeId: _asInt(map['employee_id'] ?? map['id']),
      employeeName: _asString(map['employee_name'] ?? map['name']),
      imageBase64: _asString(map['image_base64']),
    );
  }

  dynamic _normalizeData(dynamic rawData) {
    if (rawData is String) {
      final trimmed = rawData.trim();
      if (trimmed.isEmpty) {
        return <String, dynamic>{};
      }

      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return <String, dynamic>{'message': trimmed};
      }
    }

    return rawData;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    final map = _asNullableMap(value);
    if (map == null) {
      throw const FormatException('Face search response is not a JSON object.');
    }
    return map;
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
