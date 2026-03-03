import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/repositories/appraisal_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/appraisal_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

part 'appraisal_state.dart';

class AppraisalCubit extends Cubit<AppraisalState> {
  AppraisalRepository repo;
  AppraisalCubit({required this.repo}) : super(AppraisalState(loadStatus: LoadStatus.INITIAL));

  Future<void> getListAppraisals({int limit = 10, int page = 1}) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      final int offset = (page - 1) * limit;

      final _repo = await repo.getListAppraisals(0, limit, offset, page, 0);
      final List dataList = _repo.data ?? [];

      final List<AppraisalEntity> list =
          dataList.map((e) => AppraisalEntity.fromJson(e)).toList();

      emit(
        state.copyWith(
          loadStatus: LoadStatus.SUCCESS,
          listAppraisalEntities: list,
        ),
      );
    } catch (e, s) {
      logger.e("err: $e, where: $s");
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  void onChangeDateFilter(String start, String end) {
    emit(state.copyWith(startDateFilter: start, endDateFilter: end));
  }
}
