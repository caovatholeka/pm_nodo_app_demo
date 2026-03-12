import 'package:pm_app/app/data/models/entities/discipline_evaluation_detail_entity.dart';
import 'package:pm_app/app/data/models/entities/discipline_evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/work_quality_entity.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_util.dart';
import '../models/response/common_response.dart';

abstract class DashboardRepository {
  Future<CommonResponse> getRequestSumaries();
  Future<WorkQualityEntity> getWorkQuality(String month);
  Future<WorkQualityEntity> getWorkQualityDetail(String month);
  Future<dynamic> getTimeSheetData(int month);
  Future<dynamic> getBirthdaysThisMonth(int month);
  Future<DisciplineEvaluationEntity> getDisciplineEvaluation(int month);
  Future<DisciplineEvaluationDetailEntity> getDetailDisciplineEvaluation(int month);
  Future<dynamic> getProjectTasks();
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
  Future<WorkQualityEntity> getWorkQuality(String month) async {
    return await _apiClient.getWorkQuality(month);
  }

  //Thống kê chi tiết chất lượng công việc
  @override
  Future<WorkQualityEntity> getWorkQualityDetail(String month) async {
    return await _apiClient.getWorkQualityDetail(month);
  }

  //Thống kê dữ liệu chấm công
  @override
  Future<dynamic> getTimeSheetData(int month) async {
    return await _apiClient.getTimeSheetData(month);
  }

  //Thống kê sinh nhật trong tháng
  @override
  Future<dynamic> getBirthdaysThisMonth(int month) async {
    return await _apiClient.getBirthdaysThisMonth(month);
  }

  //Thống kê nề nếp
  @override
  Future<DisciplineEvaluationEntity> getDisciplineEvaluation(int month) async {
    return await _apiClient.getDisciplineEvaluation(month);
  }

  //Thống kê chi tiết nề nếp
  @override
  Future<DisciplineEvaluationDetailEntity> getDetailDisciplineEvaluation(int month) async {
    return await _apiClient.getDetailDisciplineEvaluation(month);
  }

  //Lấy chi tiết dự án 
  @override
  Future<dynamic> getProjectTasks() async {
    return await _apiClient.getProjectTasks();
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
