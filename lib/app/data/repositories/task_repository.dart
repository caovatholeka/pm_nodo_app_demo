import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/param/create_task_param.dart';
import '../models/response/common_response.dart';

abstract class TaskRepository {
  Future<CommonResponse> getListTask(String? name, int? stageId,
      int? page, int? limit);
  Future<CommonResponse> getTaskStages();
  Future<dynamic> updateTaskStage(Map<String, dynamic> body);
  Future<CommonResponse> getListUser();
  Future<CommonResponse> createTask(CreateTaskParam body);
  Future<CommonResponse> getDetailTask(int id);
  Future<dynamic> deleteTask(Map<String, dynamic> body);
  Future<CommonResponse> updateTask(CreateTaskParam body);
}

class TaskRepositoryImpl extends TaskRepository {
  // late ApiClient _apiClient;
  //
  // TaskRepositoryImpl(ApiClient client) {
  //   _apiClient = client;
  // }
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  /// Việc của mình + việc mình giao (scope=both). Không gửi scope thì server trả mọi việc
  /// user được phép xem → tài khoản Quản trị dự án thấy việc của cả công ty.
  static const String taskListScope = 'both';

  @override
  Future<CommonResponse> getListTask(String? name, int? stageId, int? page, int? limit) async {
    return await _apiClient.getListTask(name, stageId, page, limit, taskListScope);
  }

  @override
  Future<CommonResponse> getTaskStages() async {
    return await _apiClient.getTaskStages();
  }

  @override
  Future<dynamic> updateTaskStage(Map<String, dynamic> body) async {
    return await _apiClient.updateTaskStage(body);
  }

  @override
  Future<CommonResponse> getListUser() async {
    return await _apiClient.getListUser();
  }

  @override
  Future<CommonResponse> createTask(CreateTaskParam body) async {
    return await _apiClient.createTask(body);
  }

  @override
  Future<CommonResponse> getDetailTask(int id) async {
    return await _apiClient.getDetailTask(id);
  }

  @override
  Future<dynamic> deleteTask(Map<String, dynamic> body) async {
    return _apiClient.deleteTask(body);
  }

  @override
  Future<CommonResponse> updateTask(CreateTaskParam body) async {
    return _apiClient.updateTask(body);
  }
}