import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/param/create_leave_param.dart';

import '../../core/network/api_client.dart';
import '../models/response/common_response.dart';
import '../models/response/on_leave_response.dart';

abstract class OnLeaveRepository {
  Future<CommonResponse> getListTimeOnLeaves(int limit,int offset, String? startDate, String? endDate);
  Future<OnLeaveEntity> getDetailOnLeave(int id);
  Future<dynamic> deleteDetailOnLeave( int id);
  Future<OnLeaveResponse> saveOrUpdateHrLeave(UpdateOnLeaveParam param);
  Future<dynamic> confirmHrLeave(Map<String,dynamic> body);
  Future<CommonResponse> getListLeavesType();
}

class OnLeaveRepositoryImpl extends OnLeaveRepository {
  late ApiClient _apiClient;

  OnLeaveRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListTimeOnLeaves(int limit, int offset, String? startDate, String? endDate) async {
    return _apiClient.getListTimeOnLeaves(limit,offset,startDate,endDate);
  }

  @override
  Future<OnLeaveEntity> getDetailOnLeave(int id) async{
    return await _apiClient.getDetailOnLeave(id);
  }

  @override
  Future<dynamic> deleteDetailOnLeave( int id) async{
    return await _apiClient.deleteDetailOnLeave(id);
  }

  @override
  Future<OnLeaveResponse> saveOrUpdateHrLeave(UpdateOnLeaveParam param) async {
    return await _apiClient.saveOrUpdateLeave(param);
  }

  @override
  Future<dynamic> confirmHrLeave(Map<String,dynamic> body) async {
    return await _apiClient.confirmHrLeave(body);
  }

  @override
  Future<CommonResponse> getListLeavesType() async {
    return await _apiClient.getListLeavesType();
  }
}