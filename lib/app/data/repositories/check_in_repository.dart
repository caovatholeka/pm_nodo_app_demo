import '../../core/network/api_client.dart';

abstract class CheckInRepository {

}

class CheckInRepositoryImpl extends CheckInRepository {
  late ApiClient _apiClient;

  CheckInRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }
}