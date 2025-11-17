import '../../core/network/api_client.dart';
import '../models/entities/attendance_entity.dart';
import '../models/response/common_response.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year);
  Future<CommonResponse> getListAttendanceHistory();
}

class AttendanceRepositoryImpl extends AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl(this._apiClient);

  @override
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year) async {
    return _apiClient.getListAttendances(employeeId, month, year);
  }

  @override
  Future<CommonResponse> getListAttendanceHistory() async {
    return _apiClient.getListAttendanceHistory();
  }
}