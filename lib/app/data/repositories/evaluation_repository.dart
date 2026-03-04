import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/evaluation_entity.dart';
import '../models/response/common_response.dart';

abstract class EvaluationRepository {
  Future<CommonResponse> getListEvaluation(String? dateForm, String? dateTo, int limit, int page);
  Future<EvaluationEntity> getDetailEvaluation(int id);
}

class EvaluationRepositoryImpl extends EvaluationRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListEvaluation(String? dateForm, String? dateTo, int limit, int page) async{
    return await _apiClient.getListEvaluation(dateForm, dateTo, limit, page);
  }

  @override
  Future<EvaluationEntity> getDetailEvaluation(int id) async{
    return await _apiClient.getDetailEvaluation(id);
  }
}