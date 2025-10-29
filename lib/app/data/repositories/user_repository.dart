
import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class UserRepository {
  Future<CommonResponse> getUserProfile(Map<String, dynamic> body);
  // Future<dynamic> changeCurrentPass(Map<String, dynamic> body);
  // Future<CommonResponse> updateUserProfile(int userId, File file);
  // Future<List<UploadEntity>> getUserAvatar(Map<String, dynamic> body);
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

}