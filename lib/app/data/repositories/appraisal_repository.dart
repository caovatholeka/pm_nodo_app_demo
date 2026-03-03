import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';

abstract class AppraisalRepository {
    Future<CommonResponse> getListAppraisals(
    int total,
    int limit,
    int offset,
    int page,
    int totalPages,
  );
  Future<CommonResponse> getDetailAppraisal(int id);
}

class AppraisalRepositoryImpl extends AppraisalRepository {
  // final ApiClient _apiClient;
  //
  // AppraisalRepositoryImpl(this._apiClient);
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListAppraisals(int total, int limit, int offset, int page, int totalPages) async {
    return await _apiClient.getListAppraisal(total, limit, offset, page, totalPages,);
  }

  @override
  Future<CommonResponse> getDetailAppraisal(int id) async {
    return await _apiClient.getDetailAppraisal(id);
  }
}
