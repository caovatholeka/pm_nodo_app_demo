import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';

import '../../../../core/helper/response_mapper.dart';
import '../../../../data/models/enums/load_status.dart';

part 'apprasial_form_state.dart';

class ApprasialFormCubit extends Cubit<ApprasialFormState> {
  EvaluationRepository repository;

  ApprasialFormCubit({required this.repository}) : super(ApprasialFormState());

  getListEvaluation({String? dateForm, String? dateTo, int limit = 10, int page = 1}) async {
    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));
    try{
      final res = await repository.getListEvaluation(dateForm, dateTo , limit, page);
      List<EvaluationEntity>? listEvaluations;
      if (res.data != null) {
        listEvaluations = mapList<EvaluationEntity>(
          res.data,
          EvaluationEntity.fromJson,
        );
      }

      emit(
        state.copyWith(
          loadDataStatus: LoadStatus.SUCCESS,
          listEvaluations: listEvaluations ?? [],
        ),
      );

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(loadDataStatus: LoadStatus.FAILURE, listEvaluations: []),
      );
    }
  }

  getEvaluationDetails(int id) async{
    if (id == 0) {
      return;
    }

    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));
    try {
      EvaluationEntity? entity = await repository.getDetailEvaluation(id);
      emit(
        state.copyWith(loadDataStatus: LoadStatus.SUCCESS, detailEvaluation: entity),
      );
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(loadDataStatus: LoadStatus.FAILURE, detailEvaluation: null));
    }
  }

}