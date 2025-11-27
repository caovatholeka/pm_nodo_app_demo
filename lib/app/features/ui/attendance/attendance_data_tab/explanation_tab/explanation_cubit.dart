import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';

import '../../../../../core/commons/global_data.dart';
import '../../../../../data/models/enums/load_status.dart';

part 'explanation_state.dart';

class ExplanationCubit extends Cubit<ExplanationState> {
  WorkEntryRepository repository;
  ExplanationCubit({required this.repository}) : super(ExplanationState());

  void updateReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void resetSubmitSuccess() {
  emit(state.copyWith(submitSuccess: false));
}

  resetStatus(){
    emit(state.copyWith(sendInvalidStatus: LoadStatus.INITIAL));
  }



  Future<void> getListWorkEntries() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final param = {
        "limit": 40,
        "page": 1,
        "date_from": "${state.selectedYear}-${state.selectedMonth}-01",
        "date_to": "${state.selectedYear}-${state.selectedMonth}-"
            "${getLastDayOfMonth(state.selectedYear ?? DateTime.now().year
            ,state.selectedMonth ?? DateTime.now().month)}"
      };
      final res = await repository.getWorkEntries(param);
      List<WorkEntryEntity>? list;
      if(res.data != null){
        list = mapList(res.data, WorkEntryEntity.fromJson);

        if(list.isNotEmpty){
          emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listWorkEntries: list));
        }else{
          emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listWorkEntries: []));
        }
      }
    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  String getLastDayOfMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return lastDay.toString();
  }

  Future<void> sendInvalidReason(String date ,
      double? startTime, double? endTime) async {
    emit(state.copyWith(sendInvalidStatus: LoadStatus.LOADING));

    try{
      final param = {
        "employee_id": GlobalData.instance.userProfile?.employeeId,
        "date": date,
        "date_start_employee_commit": startTime ?? 8.5,
        "date_stop_employee_commit": endTime ?? 18.0,
        "note": state.reason,
      };
      final res = await repository.sendInvalid(param);
      if(res.data != null){
        emit(state.copyWith(sendInvalidStatus: LoadStatus.SUCCESS));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(sendInvalidStatus: LoadStatus.FAILURE));
    }
  }

  /*
  Future<void> sendInvalidReason() async {
    emit(state.copyWith(isLoading: true, submitSuccess: false));

    try {
      final profile = state.profile;

      if (profile == null || state.reason == null || state.reason!.isEmpty) {
        emit(state.copyWith(isLoading: false, error: "Thiếu thông tin"));
        return;
      }

      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      double startTime = now.millisecondsSinceEpoch / 1000;
      double stopTime = now.add(const Duration(hours: 8)).millisecondsSinceEpoch / 1000;

      final body = {
        "employee_id": GlobalData.instance.userProfile?.employeeId ?? 0,
        "department_id": profile.department?.id,
        "date": date,
        "date_start_employee_commit": startTime,
        "date_stop_employee_commit": stopTime,
        "note": state.reason,
      };

      await sl<ApiClient>().sendInvalid(body);

      emit(state.copyWith(
        isLoading: false,
        reason: "",
        submitSuccess: true, 
      ));

    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
   */

  void onChangeReason(String reason) {
    logger.d("reson :: $reason");
    emit(state.copyWith(reason: reason));
  }

  Future<void> setYearMonth(int year, int month) async {
    emit(state.copyWith(selectedYear: year,
        selectedMonth: month));
    // await getListAttendances(DateTime(year, month , 1));
  }
}
