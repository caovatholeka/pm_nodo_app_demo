import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
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
    emit(state.copyWith(isEdit: false, isDetail: false));
  }

  void initEdit() {
    emit(state.copyWith(isEdit: true, isDetail: false));
  }

  void initDetail() {
    emit(state.copyWith(isEdit: false, isDetail: true));
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

      bool isError = false;
      String? message;

      if (res is Map<String, dynamic>) {
        isError = res["error"] == true;
        message = res["message"]?.toString();
      } else {
        try {
          isError = res.error == true;
          message = res.message?.toString();
        } catch (_) {}
      }

      emit(
        state.copyWith(
          updateStatus: isError ? LoadStatus.FAILURE : LoadStatus.SUCCESS,
          errMsg: message,
          detailEvaluation: state.detailEvaluation,
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
}
