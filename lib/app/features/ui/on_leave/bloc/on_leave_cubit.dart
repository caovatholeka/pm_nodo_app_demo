import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';

import '../../../../core/helper/response_mapper.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/models/entities/on_leave_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';
import '../../../../data/models/param/leave_approve_param.dart';


part 'on_leave_state.dart';

class OnLeaveCubit extends Cubit<OnLeaveState> {
  OnLeaveRepository repository;

  OnLeaveCubit({required this.repository}) : super(OnLeaveState());

  void getListOnLeaveTimes() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      int limit = 10;
      int page = 1;
      String? startDate;
      String? endDate;
      final results = await repository.getListTimeOnLeaves(
        limit,
        page,
        AppDateUtils.parseDateToYMD(state.startDateFilter),
        AppDateUtils.parseDateToYMD(state.endDateFilter),
      );
      List<OnLeaveEntity>? listLeaves;
      if (results.data != null) {
        listLeaves = mapList<OnLeaveEntity>(
          results.data,
          OnLeaveEntity.fromJson,
        );
      }

      emit(
        state.copyWith(
          loadStatus: LoadStatus.SUCCESS,
          listLeaveEntities: listLeaves ?? [],
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(loadStatus: LoadStatus.FAILURE, listLeaveEntities: []),
      );
    }
  }

  onChangeDateFilter(String start, String end) {
    emit(state.copyWith(startDateFilter: start, endDateFilter: end));
  }

  void onLoadMore() async {
    if (state.loadStatus != LoadStatus.SUCCESS) return;

    final currentList = state.listLeaveEntities ?? [];
    final nextPage = (currentList.length ~/ 10) + 1;

    try {
      final results = await repository.getListTimeOnLeaves(
        20,
        nextPage,
        AppDateUtils.parseDateToYMD(state.startDateFilter),
        AppDateUtils.parseDateToYMD(state.endDateFilter),
      );

      List<OnLeaveEntity> newPage = [];
      if (results.data != null) {
        newPage = mapList<OnLeaveEntity>(results.data, OnLeaveEntity.fromJson);
      }

      if (newPage.isEmpty) {
        return;
      }

      final merged = [...currentList, ...newPage];

      emit(
        state.copyWith(
          listLeaveEntities: merged,
          loadStatus: LoadStatus.SUCCESS,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  void approveBulkLeaves(List<int> leaveIds) async {
    if(leaveIds.isEmpty) return;

    emit(state.copyWith(approveStatus: LoadStatus.LOADING));

    try{
      final param = LeaveApproveParam(leaveIds: leaveIds);
      await repository.approveLeave(param);
    }catch(e,s) {
      logger.e("err: $e");
      logger.d("where: $s");
      emit(state.copyWith(approveStatus: LoadStatus.FAILURE));
    }
  }

  void resetApproveStatus() {
    emit(state.copyWith(approveStatus: LoadStatus.INITIAL));
  }
} 
