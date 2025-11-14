import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';

abstract class WorkEntryRepository {
  Future<CommonResponse> getWorkEntries(Map<String, dynamic> body);
  Future<CommonResponse> getListLeavesType();
}

class WorkEntryRepositoryImpl extends WorkEntryRepository {
  late final ApiClient _apiClient;

  WorkEntryRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getWorkEntries(Map<String, dynamic> body) async {
    return await _apiClient.getListWorkEntry(body);
  }

  @override
  Future<CommonResponse> getListLeavesType() async {
    return await _apiClient.getListLeavesType();
  }
}
