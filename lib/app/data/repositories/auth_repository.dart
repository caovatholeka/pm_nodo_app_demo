import '../../core/network/api_client.dart';
import '../local/shared_prefs_helper.dart';
import '../models/entities/token_entity.dart';
import '../models/response/common_response.dart';

abstract class AuthRepository {
  Future<CommonResponse> authLogin(Map<String, dynamic> body);

  Future<TokenEntity?> getToken();
  Future<void> removeToken();
}

class AuthRepositoryImpl extends AuthRepository {
  late ApiClient _apiClient;

  AuthRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

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
  Future<void> removeToken() async {
    SharedPrefsHelper.saveToken(null);
  }
}