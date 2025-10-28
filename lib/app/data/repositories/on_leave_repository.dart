import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class OnLeaveRepository {
  Future<CommonResponse> getListTimeOnLeaves(Map<String, dynamic> body, int size,int number);
  Future<CommonResponse> getDetailOnLeave(int id);

}

class OnLeaveRepositoryImpl extends OnLeaveRepository {
  late ApiClient _apiClient;

  OnLeaveRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListTimeOnLeaves(Map<String, dynamic> body, int size, int number) async {
    return _apiClient.getListTimeOnLeaves(body,size,number);
  }

  @override
  Future<CommonResponse> getDetailOnLeave(int id) async{
    return await _apiClient.getDetailOnLeave(id);
  }

}