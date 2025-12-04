
import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';

abstract class CheckInRepository {
  Future<CommonResponse> getListWorkLocations();
  Future<CommonResponse> userCheckInOut(String filePath, int locationId, double latitude, double longitude);
  Future<dynamic> updateExplanation(Map<String,dynamic> body);
}

class CheckInRepositoryImpl extends CheckInRepository {
  // late ApiClient _apiClient;
  //
  // CheckInRepositoryImpl(ApiClient client) {
  //   _apiClient = client;
  // }
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListWorkLocations() async{
    return await _apiClient.getListWorkLocations();
  }

  @override
  Future<CommonResponse> userCheckInOut(String filePath,int locationId, double latitude, double longitude) async {
    FormData formData = FormData.fromMap({
      'face_image': await MultipartFile.fromFile(
          filePath
      ),
      'location_id': locationId,
      'latitude': latitude,
      'longitude' : longitude
    });

    return await _apiClient.userCheckInOut(formData);
  }
  
  @override
  Future<dynamic> updateExplanation(Map<String,dynamic> body) async {
    return await _apiClient.updateExplanation(body);
  }
}