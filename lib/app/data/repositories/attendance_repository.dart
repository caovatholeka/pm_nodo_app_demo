import '../../core/network/api_client.dart';
import '../models/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year);
}

class AttendanceRepositoryImpl extends AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl(this._apiClient);

  @override
  Future<List<AttendanceEntity>> getListAttendances(int? employeeId, int? month, int? year) async {
    return _apiClient.getListAttendances(employeeId, month, year);
  }
}