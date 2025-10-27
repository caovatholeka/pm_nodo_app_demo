import '../../core/network/api_client.dart';
import '../local/shared_prefs_helper.dart';
import '../models/entities/token_entity.dart';

abstract class AuthRepository {
  Future<TokenEntity?> getToken();
  Future<void> removeToken();
}

class AuthRepositoryImpl extends AuthRepository {
  late ApiClient _apiClient;

  AuthRepositoryImpl(ApiClient client) {
    _apiClient = client;
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