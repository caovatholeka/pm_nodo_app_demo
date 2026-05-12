import 'package:pm_app/app/data/models/entities/evaluation_asess_entity.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/evaluation_entity.dart';
import '../models/response/common_response.dart';

abstract class EvaluationRepository {
  Future<CommonResponse> getListEvaluation(
    String? dateForm,
    String? dateTo,
    int limit,
    int page,
  );
  Future<EvaluationEntity> getDetailEvaluation(int id);
  Future<CommonResponse> createEvaluation(EvaluationEntity body);
  Future<dynamic> updateEvaluation(int id, Map<String, dynamic> body);
  Future<CommonResponse> submitEvaluation(int id);
  Future<EvaluationAsessEntity> assessEvaluation(int id, Map<String, dynamic> body);
  Future<CommonResponse> approvedEvaluation(int id);
  Future<CommonResponse> getListJob(int limit, int offset);
}

class EvaluationRepositoryImpl extends EvaluationRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListEvaluation(
    String? dateForm,
    String? dateTo,
    int limit,
    int page,
  ) async {
    return await _apiClient.getListEvaluation(dateForm, dateTo, limit, page);
  }

  @override
  Future<EvaluationEntity> getDetailEvaluation(int id) async {
    return await _apiClient.getDetailEvaluation(id);
  }

  @override
  Future<CommonResponse> createEvaluation(EvaluationEntity body) async {
    return await _apiClient.createEvaluation(body);
  }

  @override
  Future<dynamic> updateEvaluation(int id, Map<String, dynamic> body) async {
    return await _apiClient.updateEvaluation(id, body);
  }

  @override
  Future<CommonResponse> submitEvaluation(int id) async {
    return await _apiClient.submitEvaluation(id);
  }

  @override
  Future<EvaluationAsessEntity> assessEvaluation(int id, Map<String, dynamic> body) async {
    return await _apiClient.assessEvaluation(id, body);
  }

  @override
  Future<CommonResponse> approvedEvaluation(int id) async {
    return await _apiClient.approvedEvaluation(id);
  }

  @override
  Future<CommonResponse> getListJob(int limit, int offset) async {
    return await _apiClient.getListJobs(limit, offset);
  }
}
