import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';

import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';

abstract class OnLeaveRepository {
  Future<CommonResponse> getListTimeOnLeaves(int limit,int offset);
  Future<OnLeaveEntity> getDetailOnLeave(int id);
  Future<dynamic> deleteDetailOnLeave( int id);
}

class OnLeaveRepositoryImpl extends OnLeaveRepository {
  late ApiClient _apiClient;

  OnLeaveRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListTimeOnLeaves(int limit, int offset) async {
    return _apiClient.getListTimeOnLeaves(limit,offset);
  }

  @override
  Future<OnLeaveEntity> getDetailOnLeave(int id) async{
    return await _apiClient.getDetailOnLeave(id);
  }

  @override
  Future<dynamic> deleteDetailOnLeave( int id) async{
    return await _apiClient.deleteDetailOnLeave(id);
  }
}