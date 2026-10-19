import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/core/network/api_util.dart';
import 'package:pm_app/app/data/models/entities/checkpoint_entity.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';

abstract class CheckpointRepository {
  Future<CommonResponse> getListCheckpoint(String? dateFrom, String? dateTo);
  Future<CheckpointEntity> submitCheckpoint(int id);
}

class CheckpointRepositoryImpl extends CheckpointRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListCheckpoint(
    String? dateFrom,
    String? dateTo,
  ) async {
    return _apiClient.getListCP(dateFrom, dateTo);
  }

  @override
  Future<CheckpointEntity> submitCheckpoint(int id) async {
    return _apiClient.submitCheckpoint(id);
  }
}
