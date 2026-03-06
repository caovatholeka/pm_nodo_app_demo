import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';

part 'create_apprasial_state.dart';

class CreateAppraisalCubit extends Cubit<CreateAppraisalState> {
  EvaluationRepository repository;

  CreateAppraisalCubit({required this.repository}) : super(const CreateAppraisalState());


  void setFromDate(DateTime date) {
    emit(
      state.copyWith(
        fromDate: date,
        resetLines: true,
      )
    );
  }

  void setToDate(DateTime date) {
    emit(
      state.copyWith(
        toDate: date,
        resetLines: true,
      ),
    );
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
    emit(state.copyWith(
      isCreate: true,
      isDetail: false,
    ));
  }

  void initDetail() {
    emit(state.copyWith(
      isCreate: false,
      isDetail: true,
    ));
  }

    getEvaluationDetails(int id) async{
    if (id == 0) {
      return;
    }

    emit(state.copyWith(loadDetail: LoadStatus.LOADING));
    try {
      EvaluationEntity? entity = await repository.getDetailEvaluation(id);

      logger.e('Evaluation detail: $entity');
      logger.e('Evaluation detail form type: ${entity?.taskLineIds}');
      emit(
        state.copyWith(loadDetail: LoadStatus.SUCCESS, detailEvaluation: entity),
      );
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(loadDetail: LoadStatus.FAILURE, detailEvaluation: null));
    }
  }
}
