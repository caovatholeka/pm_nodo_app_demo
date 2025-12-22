
import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/param/create_work_trip_param.dart';
import '../models/response/common_response.dart';
import '../models/response/work_trip_response.dart';

abstract class WorkTripRepository {
  Future<CommonResponse> getListBusinessTrip();
  Future<CommonResponse> getListEmployees({
    int? limit,
    int? page,
    String? name,
    String? code,
    String? email,
    int? departmentId,
    int? jobTitleId,
    String? active,
  });

  Future<WorkTripResponse> createBusinessTrip(CreateWorkTripParam body);
}

class WorkTripRepositoryImpl extends WorkTripRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<CommonResponse> getListBusinessTrip() async {
    return await _apiClient.getListBusinessTrip();
  }

  @override
  Future<WorkTripResponse> createBusinessTrip(CreateWorkTripParam body) async {
    return await _apiClient.createBusinessTrip(body);
  }

  @override
  Future<CommonResponse> getListEmployees({
    int? limit,
    int? page,
    String? name,
    String? code,
    String? email,
    int? departmentId,
    int? jobTitleId,
    String? active,
  }) {
    return _apiClient.getListEmployees(
      limit,
      page,
      name,
      code,
      email,
      departmentId,
      jobTitleId,
      active,
    );
  }
}