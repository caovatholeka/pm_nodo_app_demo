import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/param/create_overtime_param.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';

abstract class OvertimeRepository {
  Future<CommonResponse> getListOT({Map<String, dynamic>? params});
  Future<OvertimeEntity> getOTDetail(int id);
  Future<CommonResponse> createOTRequest(CreateOvertimeParam body);
  Future<dynamic> updateOTRequest(int id, Map<String, dynamic> body);
  Future<OvertimeEntity> submitOTP(int id);
  Future<dynamic> deleteOTRequest(int id);
}

class OvertimeRepositoryImpl extends OvertimeRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListOT({Map<String, dynamic>? params}) async{
    return await _apiClient.getListOT(params);
  }

  @override
  Future<OvertimeEntity> getOTDetail(int id) async{
    return await _apiClient.getDetailOT(id);
  }

  @override
  Future<CommonResponse> createOTRequest(CreateOvertimeParam body) async {
    return await _apiClient.createOTRequest(body.toJson());
  }

  @override
  Future<dynamic> updateOTRequest(int id, Map<String, dynamic> body) async {
    return _apiClient.updateOTRequest(id, body);
  }

  @override
  Future<OvertimeEntity> submitOTP(int id) async {
    return _apiClient.submitOT(id);
  }

  @override
  Future<dynamic> deleteOTRequest(int id) async{
    return _apiClient.deleteOTRequest(id);
  }
}

