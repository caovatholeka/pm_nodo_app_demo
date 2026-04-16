import 'package:pm_app/app/data/models/entities/discipline_evaluation_detail_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';

abstract class DashboardRepository {
  Future<CommonResponse> getRequestSumaries();
  Future<WorkQualityEntity> getWorkQuality(int month, int year);
  Future<WorkQualityEntity> getWorkQualityDetail(int month, int year);
  Future<dynamic> getTimeSheetData(int month, int year);
  Future<dynamic> getBirthdaysThisMonth(int month);
  Future<DisciplineEvaluationEntity> getDisciplineEvaluation(int month, int year);
  Future<DisciplineEvaluationDetailEntity> getDetailDisciplineEvaluation(int month, int year);
  Future<dynamic> getProjectTasks(int projectId);
  Future<dynamic> getProjects();
  Future<CommonResponse> submitImprovemnt(SendSuggestionParam body);
}

class DashboardRepositoryImpl implements DashboardRepository {
  ApiClient get _apiClient => ApiUtil.instance.createApiClient();

  //Thống kê đơn từ
  @override
  Future<CommonResponse> getRequestSumaries() async {
    return await _apiClient.getRequestSumaries();
  }

  //Thống kê chất lượng công việc
  @override
  Future<WorkQualityEntity> getWorkQuality(int month, int year) async {
    return await _apiClient.getWorkQuality(month, year);
  }

  //Thống kê chi tiết chất lượng công việc
  @override
  Future<WorkQualityEntity> getWorkQualityDetail(int month, int year) async {
    return await _apiClient.getWorkQualityDetail(month, year);
  }

  //Thống kê dữ liệu chấm công
  @override
  Future<dynamic> getTimeSheetData(int month, int year) async {
    return await _apiClient.getTimeSheetData(month, year);
  }

  //Thống kê sinh nhật trong tháng
  @override
  Future<dynamic> getBirthdaysThisMonth(int month) async {
    return await _apiClient.getBirthdaysThisMonth(month);
  }

  //Thống kê nề nếp
  @override
  Future<DisciplineEvaluationEntity> getDisciplineEvaluation(int month, int year) async {
    return await _apiClient.getDisciplineEvaluation(month, year);
  }

  //Thống kê chi tiết nề nếp
  @override
  Future<DisciplineEvaluationDetailEntity> getDetailDisciplineEvaluation(int month, int year) async {
    return await _apiClient.getDetailDisciplineEvaluation(month, year);
  }

  //Lấy chi tiết dự án 
  @override
  Future<dynamic> getProjectTasks(int projectId) async {
    return await _apiClient.getProjectTasks(projectId);
  }

  //Lấy dự án
  @override
  Future<dynamic> getProjects() async {
    return await _apiClient.getProjects();
  }

  //Đề xuất cải thiện
  @override
  Future<CommonResponse> submitImprovemnt(SendSuggestionParam body) async {
    return await _apiClient.submitImprovemnt(body);
  }
}
