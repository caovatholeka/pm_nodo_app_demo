import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/job_title_list_entity.dart';
import 'package:pm_app/app/data/models/entities/job_title_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';

import '../../../../data/models/entities/master_data_item.dart';

part 'detail_apprasial_state.dart';

class CreateAppraisalCubit extends Cubit<CreateAppraisalState> {
  EvaluationRepository repository;

  CreateAppraisalCubit({required this.repository})
    : super(const CreateAppraisalState());

  void setFromDate(DateTime date) {
    emit(state.copyWith(fromDate: date, clearToDate: true, resetLines: true));
  }

  void setToDate(DateTime date) {
    emit(state.copyWith(toDate: date, resetLines: true));
  }

  void setNote(String value) {
    emit(state.copyWith(note: value));
  }

  void setHour(int index, double? value) {
    final map = Map<int, double?>.from(state.hours);
    map[index] = value;
    emit(state.copyWith(hours: map));
  }

  void setFormType(int index, String? value) {
    final map = Map<int, String?>.from(state.formTypes);
    map[index] = value;
    emit(state.copyWith(formTypes: map));
  }

  Future<void> submit() async {
    if (!state.isFormValid) return;

    emit(state.copyWith(isSubmitting: true));

    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(isSubmitting: false));
  }

  void initCreate() {
    emit(
      state.copyWith(
        isEdit: false,
        isDetail: false,
        isHRReview: false,
        isManagerAssess: false,
        detailEvaluation: null,
        currentTabIndex: 0,
        currentTabItem: null,
      ),
    );
  }

  void initEdit() {
    emit(
      state.copyWith(
        isEdit: true,
        isDetail: false,
        isHRReview: false,
        isManagerAssess: false,
        currentTabIndex: 0,
        currentTabItem: null,
      ),
    );
  }

  void initDetail() {
    emit(
      state.copyWith(
        isEdit: false,
        isDetail: true,
        isHRReview: false,
        isManagerAssess: false,
        currentTabIndex: 0,
        currentTabItem: null,
      ),
    );
  }

  void initHrReview() {
    emit(
      state.copyWith(
        isEdit: true,
        isDetail: false,
        isHRReview: true,
        isManagerAssess: false,
        currentTabIndex: 0,
        currentTabItem: const MasterDataItem(id: 0),
      ),
    );
  }

  void initManagerAssess() {
    emit(
      state.copyWith(
        isEdit: true,
        isDetail: false,
        isHRReview: false,
        isManagerAssess: true,
        currentTabIndex: 0,
        currentTabItem: const MasterDataItem(id: 0),
      ),
    );
  }

  getEvaluationDetails(int id) async {
    if (id == 0) {
      return;
    }

    emit(state.copyWith(loadDetail: LoadStatus.LOADING));
    try {
      EvaluationEntity? entity = await repository.getDetailEvaluation(id);
      emit(
        state.copyWith(
          loadDetail: LoadStatus.SUCCESS,
          detailEvaluation: entity,
        ),
      );
    } catch (e) {
      logger.d(e);
      emit(
        state.copyWith(loadDetail: LoadStatus.FAILURE, detailEvaluation: null),
      );
    }
  }

  Future<void> updateEvaluation(int id, Map<String, dynamic> body) async {
    if (id == 0) return;

    emit(state.copyWith(updateStatus: LoadStatus.LOADING, errMsg: ""));

    try {
      logger.d("updateEvaluation payload: $body");
      final res = await repository.updateEvaluation(id, body);
      logger.d("updateEvaluation response: $res");
      final isError = _responseHasError(res);
      final message = _responseMessage(res);

      EvaluationEntity? updatedDetail = state.detailEvaluation;
      if (!isError) {
        try {
          updatedDetail = await repository.getDetailEvaluation(id);
        } catch (e, s) {
          logger.d(e);
          logger.d(s);
        }
      }

      emit(
        state.copyWith(
          updateStatus: isError ? LoadStatus.FAILURE : LoadStatus.SUCCESS,
          errMsg: message,
          detailEvaluation: updatedDetail,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(updateStatus: LoadStatus.FAILURE, errMsg: e.toString()),
      );
    }
  }

  Future<void> createEvaluation(EvaluationEntity body) async {
    emit(state.copyWith(updateStatus: LoadStatus.LOADING, errMsg: ""));

    try {
      logger.d("createEvaluation payload: ${body.toJson()}");
      final res = await repository.createEvaluation(body);
      logger.d("createEvaluation response: ${res.toJson()}");

      final isError = res.error == true;
      final message = res.message?.toString();

      EvaluationEntity? createdDetail = state.detailEvaluation;
      final createdId = _extractEvaluationId(res.data);

      if (!isError && createdId != null && createdId > 0) {
        try {
          createdDetail = await repository.getDetailEvaluation(createdId);
        } catch (e, s) {
          logger.d(e);
          logger.d(s);
        }
      }

      emit(
        state.copyWith(
          updateStatus: isError ? LoadStatus.FAILURE : LoadStatus.SUCCESS,
          errMsg: message,
          detailEvaluation: createdDetail,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(updateStatus: LoadStatus.FAILURE, errMsg: e.toString()),
      );
    }
  }

  Future<void> assessEvaluation(int id, Map<String, dynamic> body) async {
    if (id == 0) return;

    emit(state.copyWith(updateStatus: LoadStatus.LOADING, errMsg: ""));

    try {
      logger.d("assessEvaluation payload: $body");
      await repository.assessEvaluation(id, body);

      EvaluationEntity? updatedDetail = state.detailEvaluation;
      try {
        updatedDetail = await repository.getDetailEvaluation(id);
      } catch (e, s) {
        logger.d(e);
        logger.d(s);
      }

      emit(
        state.copyWith(
          updateStatus: LoadStatus.SUCCESS,
          errMsg: "Đánh giá HR thành công",
          detailEvaluation: updatedDetail,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(updateStatus: LoadStatus.FAILURE, errMsg: e.toString()),
      );
    }
  }

  void resetUpdateStatus() {
    emit(state.copyWith(updateStatus: LoadStatus.INITIAL));
  }

  void onChangeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  void onChangeCurrentTabItem(MasterDataItem item) {
    emit(state.copyWith(currentTabItem: item));
  }

  Future<void> getListJob({
    int limit = 1000,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state.loadJobStatus == LoadStatus.SUCCESS &&
        (state.jobTitles?.isNotEmpty ?? false)) {
      return;
    }

    emit(state.copyWith(loadJobStatus: LoadStatus.LOADING));

    try {
      final response = await repository.getListJob(limit, offset);
      final jobTitleListEntity = JobTitleListEntity.fromJson({
        'data': response.data,
      });

      emit(
        state.copyWith(
          loadJobStatus: LoadStatus.SUCCESS,
          jobTitles: jobTitleListEntity.data,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(loadJobStatus: LoadStatus.FAILURE, jobTitles: const []),
      );
    }
  }

  int? _extractEvaluationId(dynamic data) {
    if (data == null) return null;

    if (data is int) return data;
    if (data is String) return int.tryParse(data);

    if (data is Map<String, dynamic>) {
      final directId = data["id"] ?? data["evaluation_id"];
      if (directId is int) return directId;
      if (directId is String) return int.tryParse(directId);

      final nestedData = data["data"];
      if (nestedData is Map<String, dynamic>) {
        final nestedId = nestedData["id"] ?? nestedData["evaluation_id"];
        if (nestedId is int) return nestedId;
        if (nestedId is String) return int.tryParse(nestedId);
      }
    }

    return null;
  }

  bool _responseHasError(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response["error"] == true;
    }

    try {
      return response.error == true;
    } catch (_) {
      return false;
    }
  }

  String? _responseMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response["message"]?.toString();
    }

    try {
      return response.message?.toString();
    } catch (_) {
      return null;
    }
  }
}
