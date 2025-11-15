import 'dart:io';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class CheckInRepository {
  Future<CommonResponse> getListWorkLocations();
  Future<CommonResponse> userCheckInOut(String filePath, int locationId, double latitude, double longitude);
}

class CheckInRepositoryImpl extends CheckInRepository {
  late ApiClient _apiClient;

  CheckInRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

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
}