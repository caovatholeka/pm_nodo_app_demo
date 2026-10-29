import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../core/network/api_util.dart';

class MasterData {
  /// Nhãn trạng thái nhân viên hiển thị trong bộ lọc — theo ngôn ngữ hiện tại.
  /// (Getter, không phải hằng: S.current chỉ có sau khi app load ngôn ngữ.)
  static List<String> get employeeStatuses => [
    S.current.profile_work,
    S.current.profile_not_work,
  ];

  /// Khoá so sánh cũ (nhãn tiếng Việt) → giá trị API. Giữ nguyên, không dịch.
  static const Map<String, String> employeeStatusApiMap = {
    'Đang làm việc': 'working',
    'Đã nghỉ việc': 'stop',
  };

  static String? encodeEmployeeStatus(String? status) {
    if (status == null || status.isEmpty) return null;
    if (status == S.current.profile_work) return 'working';
    if (status == S.current.profile_not_work) return 'stop';
    return employeeStatusApiMap[status];
  }

  static Future<List<MasterDataItem>> getDepartmentsFromApi({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // final apiClient = GetIt.I<ApiClient>();
      ApiClient  apiClient = ApiUtil.instance.createApiClient();
      final CommonResponse response = await apiClient.getListDepartments(
        limit,
        offset,
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> rawList = response.data as List<dynamic>;

        final List<MasterDataItem> departments =
            rawList.map((e) {
              if (e is Map<String, dynamic>) {
                final int? id =
                    e['id'] is int
                        ? e['id']
                        : int.tryParse(e['id']?.toString() ?? '');
                final String? name =
                    e['name'] ??
                    e['departmentName'] ??
                    e['department'] ??
                    e['text'] ??
                    '';
                return MasterDataItem(
                  id: id,
                  name: name,
                  text: name,
                  code: e['code']?.toString(),
                );
              }
              return MasterDataItem(
                id: null,
                name: e.toString(),
                text: e.toString(),
              );
            }).toList();

        final filtered =
            departments
                .where((d) => (d.name?.isNotEmpty ?? false))
                .toSet()
                .toList()
              ..sort((a, b) => a.name!.compareTo(b.name!));

        return filtered;
      }

      return [];
    } catch (e, s) {
      print('❌ Lỗi khi lấy danh sách phòng ban: $e');
      print(s);
      return [];
    }
  }

  static Future<List<MasterDataItem>> getJobTitlesFromApi({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // final apiClient = GetIt.I<ApiClient>();
      ApiClient  apiClient = ApiUtil.instance.createApiClient();
      final CommonResponse response = await apiClient.getListJobs(
        limit,
        offset,
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> rawList = response.data as List<dynamic>;

        final List<MasterDataItem> jobTitles =
            rawList.map((e) {
              if (e is Map<String, dynamic>) {
                final int? id =
                    e['id'] is int
                        ? e['id']
                        : int.tryParse(e['id']?.toString() ?? '');
                final String? name =
                    e['name'] ??
                    e['jobTitleName'] ??
                    e['title'] ??
                    e['text'] ??
                    '';
                return MasterDataItem(
                  id: id,
                  name: name,
                  text: name,
                  code: e['code']?.toString(),
                );
              }
              return MasterDataItem(
                id: null,
                name: e.toString(),
                text: e.toString(),
              );
            }).toList();

        final filtered =
            jobTitles
                .where((j) => (j.name?.isNotEmpty ?? false))
                .toSet()
                .toList()
              ..sort((a, b) => a.name!.compareTo(b.name!));

        return filtered;
      }

      return [];
    } catch (e, s) {
      print('❌ Lỗi khi lấy danh sách chức vụ: $e');
      print(s);
      return [];
    }
  }
}
