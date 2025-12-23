
import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/work_trip_entity.dart';
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

  Future<WorkTripEntity> getDetailWorkTrip(int id);

  Future<CommonResponse> submitWorkTrip(CreateWorkTripParam body,int id);

  Future<CommonResponse> deleteWorkTrip(int id);

  Future<WorkTripResponse> updateWorkTrip(CreateWorkTripParam body, int id);

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

  @override
  Future<WorkTripEntity> getDetailWorkTrip(int id) async {
    return _apiClient.getDetailWorkTrip(id);
  }

  @override
  Future<CommonResponse> submitWorkTrip(CreateWorkTripParam body,int id) async {
    return await _apiClient.submitWorkTrip(body,id);
  }

  @override
  Future<CommonResponse> deleteWorkTrip(int id) async {
    return await _apiClient.deleteWorkTrip(id);
  }

  @override
  Future<WorkTripResponse> updateWorkTrip(CreateWorkTripParam body, int id) async{
    return _apiClient.updateWorkTrip(body, id);
  }
}