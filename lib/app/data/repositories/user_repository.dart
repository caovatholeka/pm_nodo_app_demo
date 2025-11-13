

import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class UserRepository {
  Future<CommonResponse> getUserProfile(Map<String, dynamic> body);
  Future<dynamic> changeCurrentPass(Map<String, dynamic> body);

  Future<CommonResponse> getListWorkFlowStages();
  Future<CommonResponse> getListWorkEntryTypes();
}

class UserRepositoryImpl extends UserRepository {
  late ApiClient _apiClient;

  UserRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getUserProfile(Map<String, dynamic> body) async{
    return await _apiClient.getUserProfile(body);
  }

  @override
  Future<CommonResponse> changeCurrentPass(Map<String, dynamic> body) async {
      return await _apiClient.changePassword(body);
  }

  @override
  Future<CommonResponse> getListWorkFlowStages() async {
      return await _apiClient.getListWorkFlowStages();
  }

  @override
  Future<CommonResponse> getListWorkEntryTypes() async {
    return await _apiClient.getListWorkEntryTypes();
  }
}