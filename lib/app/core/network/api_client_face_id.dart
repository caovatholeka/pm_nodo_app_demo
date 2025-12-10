import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import '../../config/app_config.dart';
import '../../data/models/entities/face_search_response_entity.dart';

part 'api_client_face_id.g.dart';

@RestApi()
abstract class ApiClientFaceId {
  factory ApiClientFaceId(Dio dio, {String baseUrl}) = _ApiClientFaceId;

  ///GET LIST
  @POST('/api/v1/faces/search-face')
  Future<FaceSearchResponseEntity> searchFaceEmployee(@Body() FormData? body);
}