import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/param/create_justification_param.dart';
import '../models/response/common_response.dart';

abstract class JutificationRepository {
  Future<CommonResponse> getAttendanceList({Map<String, dynamic>? params});
  Future<CommonResponse> createJustification(CreateJustificationParam body);
  Future<dynamic> updateJustification(int id, Map<String, dynamic> body);
  Future<JustificationEntity> submitJustification(int id);
  Future<JustificationEntity> getDetailAttendance(int id);
  Future<dynamic> deleteJustification(int id);
  Future<CommonResponse> approveJustification(JustificationApproveParam body);
  Future<CommonResponse> cancelJustification(int id, JustificationCancelParam body);
}

class JutificationRepositoryImpl extends JutificationRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getAttendanceList({Map<String, dynamic>? params}) async {
    return await _apiClient.getAttendanceList(params);
  }

  @override
  Future<JustificationEntity> getDetailAttendance(int id) async {
    return await _apiClient.getDetailAttendance(id);
  }

  @override
  Future<CommonResponse> createJustification(
    CreateJustificationParam body,
  ) async {
    return await _apiClient.createAttendance(body.toJson());
  }

  @override
  Future<dynamic> updateJustification(int id, Map<String, dynamic> body) async {
    return await _apiClient.updateAttendance(id, body);
  }

  @override
  Future<JustificationEntity> submitJustification(int id) async {
    return await _apiClient.submitAttendance(id);
  }

  @override
  Future<dynamic> deleteJustification(int id) async {
    return await _apiClient.deleteAttendance(id);
  }

  @override
  Future<CommonResponse> approveJustification(JustificationApproveParam body) async {
    return await _apiClient.approveJustification(body);
  }

  @override
  Future<CommonResponse> cancelJustification(int id, JustificationCancelParam body) async {
    return await _apiClient.cancelJustification(id, body);
  }
}
