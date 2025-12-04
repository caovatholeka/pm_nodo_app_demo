import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../local/shared_prefs_helper.dart';
import '../models/entities/token_entity.dart';
import '../models/response/common_response.dart';

abstract class AuthRepository {
  Future<CommonResponse> authLogin(Map<String, dynamic> body);

  Future<TokenEntity?> getToken();
  Future<void> saveToken(TokenEntity token);
  Future<void> removeToken();

  Future<int?> getUserId();
  Future<void> saveUserId(int uId);
}

class AuthRepositoryImpl extends AuthRepository {
  // late ApiClient _apiClient;
  //
  // AuthRepositoryImpl(ApiClient client) {
  //   _apiClient = client;
  // }
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> authLogin(Map<String, dynamic> body) {
    return _apiClient.authLogin(body);
  }

  @override
  Future<TokenEntity?> getToken() async {
    // return SecureStorage.getInstance().getToken();
    return SharedPrefsHelper.getToken();
  }

  @override
  Future<void> saveToken(TokenEntity token) async {
    SharedPrefsHelper.saveToken(token);
  }

  @override
  Future<void> removeToken() async {
    SharedPrefsHelper.saveToken(null);
  }

  @override
  Future<int?> getUserId() async{
    return SharedPrefsHelper.getUserId();
  }

  @override
  Future<void> saveUserId(int uId) async {
    SharedPrefsHelper.setUserId(uId);
  }

}