import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/evaluation_entity.dart';
import '../models/response/common_response.dart';

abstract class EvaluationRepository {
  Future<CommonResponse> getListEvaluation();
  Future<EvaluationEntity> getDetailEvaluation(int id);
}

class EvaluationRepositoryImpl extends EvaluationRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListEvaluation() async{
    return await _apiClient.getListEvaluation();
  }

  @override
  Future<EvaluationEntity> getDetailEvaluation(int id) async{
    return await _apiClient.getDetailEvaluation(id);
  }
}