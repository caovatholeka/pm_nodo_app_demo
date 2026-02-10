import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';
import 'package:pm_app/app/data/models/param/create_leave_param.dart';
import 'package:pm_app/app/data/models/param/leave_approve_param.dart';
import 'package:pm_app/app/data/models/param/leave_reject_param.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';
import '../models/response/on_leave_response.dart';

abstract class OnLeaveRepository {
  Future<CommonResponse> getListTimeOnLeaves(int limit,int page, String? startDate, String? endDate);
  Future<OnLeaveEntity> getDetailOnLeave(int id);
  Future<dynamic> deleteDetailOnLeave( int id);
  Future<OnLeaveResponse> saveOrUpdateHrLeave(UpdateOnLeaveParam param);
  Future<dynamic> confirmHrLeave(Map<String,dynamic> body);
  Future<CommonResponse> getListLeavesType();
  Future<CommonResponse> approveLeave(LeaveApproveParam param);
  Future<CommonResponse> rejectLeave(int id, LeaveRejectParam param);
}

class OnLeaveRepositoryImpl extends OnLeaveRepository {
  // late ApiClient _apiClient;
  //
  // OnLeaveRepositoryImpl(ApiClient client) {
  //   _apiClient = client;
  // }
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListTimeOnLeaves(int limit, int page, String? startDate, String? endDate) async {
    return _apiClient.getListTimeOnLeaves(limit,page,startDate,endDate);
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

  @override
  Future<CommonResponse> approveLeave(LeaveApproveParam param) async {
    return await _apiClient.approveLeave(param);
  }
  
  @override
  Future<CommonResponse> rejectLeave(int id, LeaveRejectParam param) async {
    return await _apiClient.cancelLeave(id, param);
  }
}
