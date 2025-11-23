import '../../core/network/api_client.dart';
import '../models/param/create_task_param.dart';
import '../models/response/common_response.dart';

abstract class TaskRepository {
  Future<CommonResponse> getListTask(String? name, int? stageId);
  Future<CommonResponse> getTaskStages();
  Future<dynamic> updateTaskStage(Map<String, dynamic> body);
  Future<CommonResponse> getListUser();
  Future<dynamic> createTask(CreateTaskParam body);
  Future<CommonResponse> getDetailTask(int id);
  Future<dynamic> deleteTask(Map<String, dynamic> body);
  Future<CommonResponse> updateTask(CreateTaskParam body);
}

class TaskRepositoryImpl extends TaskRepository {
  late ApiClient _apiClient;

  TaskRepositoryImpl(ApiClient client) {
    _apiClient = client;
  }

  @override
  Future<CommonResponse> getListTask(String? name, int? stageId) async {
    return await _apiClient.getListTask(name, stageId);
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
  Future<dynamic> createTask(CreateTaskParam body) async {
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