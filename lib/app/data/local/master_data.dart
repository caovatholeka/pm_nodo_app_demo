import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';

class MasterData {

  static const List<String> employeeStatuses = [
    'Đang làm việc', 
    'Đã nghỉ việc',  
  ];

static Future<List<String>> getDepartmentsFromApi({
    int limit = 1,
    int offset = 0,
  }) async {
    try {
      final apiClient = GetIt.I<ApiClient>(); 
      final CommonResponse response = await apiClient.getListDepartments(limit, offset);

      if (response.data != null && response.data is List) {
        final List<dynamic> rawList = response.data as List<dynamic>;

        final List<String> departments = rawList
            .map<String>((e) {
              if (e is Map<String, dynamic>) {
                return e['name'] ?? e['departmentName'] ?? '';
              }
              return e.toString();
            })
            .where((d) => d.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return departments;
      }

      return [];
    } catch (e, s) {
      print('❌ Lỗi khi lấy danh sách phòng ban: $e');
      print(s);
      return [];
    }
  }

  static List<String> getJobTitlesFromEmployees(List<EmployeeEntity> employees) {
    final jobTitles = employees
        .map((e) => e.jobTitle)
        .where((j) => j != null && j.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return jobTitles.cast<String>();
  }
}
