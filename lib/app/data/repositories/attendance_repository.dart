import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/entities/attendance_entity.dart';
import '../models/response/common_response.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year);
  Future<CommonResponse> getListAttendanceHistory(String? dateFrom,String? dateTo);
  // chi tiet cham cong
  Future<CommonResponse> getDetailWorkEntry(int attendanceId);

}

class AttendanceRepositoryImpl extends AttendanceRepository {
  // final ApiClient _apiClient;
  //
  // AttendanceRepositoryImpl(this._apiClient);
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  @override
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year) async {
    return _apiClient.getListAttendances(employeeId, month, year);
  }

  @override
  Future<CommonResponse> getListAttendanceHistory(String? dateFrom,String? dateTo) async {
    return _apiClient.getListAttendanceHistory(dateFrom,dateTo);
  }

  @override
  Future<CommonResponse> getDetailWorkEntry(int attendanceId) async {
    return await _apiClient.getDetailWorkEntry(attendanceId);
  }
}