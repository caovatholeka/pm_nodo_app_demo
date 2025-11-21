import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class UserRepository {
  Future<CommonResponse> getUserProfile(Map<String, dynamic> body);
  Future<dynamic> changeCurrentPass(Map<String, dynamic> body);

  Future<CommonResponse> getListWorkFlowStages();
  Future<CommonResponse> getListWorkEntryTypes();
  Future<dynamic> forgotPassword(Map<String, dynamic> body);
  Future<dynamic> sendOTP(Map<String, dynamic> body);
  Future<dynamic> verifyOtp(Map<String, dynamic> body);
  Future<CommonResponse> getNotification(Map<String, dynamic> body);
  Future<CommonResponse> markNotiRead(int id);
}

class UserRepositoryImpl extends UserRepository {
  late ApiClient _apiClient;

  UserRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getUserProfile(Map<String, dynamic> body) async {
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

  @override
  Future<CommonResponse> forgotPassword(Map<String, dynamic> body) async {
    return await _apiClient.forgotPassword(body);
  }

  @override
  Future<CommonResponse> sendOTP(Map<String, dynamic> body) async {
    return await _apiClient.sendOTP(body);
  }

  @override
  Future<CommonResponse> verifyOtp(Map<String, dynamic> body) async {
    return await _apiClient.verifyOtp(body);
  }

  @override
  Future<CommonResponse> getNotification(Map<String, dynamic> body) async {
    return await _apiClient.getNotification(body);
  }

  @override
  Future<CommonResponse> markNotiRead(int id) {
    return _apiClient.markNotiRead(id);
  }
}
