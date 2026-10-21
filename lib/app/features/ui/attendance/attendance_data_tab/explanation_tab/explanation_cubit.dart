import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';

import '../../../../../core/commons/global_data.dart';
import '../../../../../core/utils/utils.dart';
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

  resetData(){
    emit(state.copyWith(reason:"",
      startTime: "",
      endTime: ""
    ));
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

  Future<void> sendInvalidReason(String date) async {
    if (state.sendInvalidStatus == LoadStatus.LOADING) return; // chống bấm gửi 2 lần
    emit(state.copyWith(sendInvalidStatus: LoadStatus.LOADING));
    try{
      final param = {
        "employee_id": GlobalData.instance.userProfile?.employeeId,
        "date": date,
        "date_start_employee_commit": Utils().stringTimeToFloat(state.startTime) ?? 8.5,
        "date_stop_employee_commit": Utils().stringTimeToFloat(state.endTime) ?? 18.0,
        "note": state.reason,
      };
      final res = await repository.sendInvalid(param);
      if(res.data != null){
        emit(state.copyWith(sendInvalidStatus: LoadStatus.SUCCESS));
      }else{
        emit(state.copyWith(sendInvalidStatus: LoadStatus.FAILURE,errorMsg: res.message));
      }
    }on DioException catch(e){
      String errMsg = 'Có lỗi xảy ra, vui lòng thử lại sau';

      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;

        // Trường hợp BE trả map JSON: {"code":404,"message":"***"}
        if (data is Map<String, dynamic>) {
          errMsg = data['message']?.toString() ?? errMsg;
        }
        // Trường hợp Retrofit/Dio trả về String JSON, ví dụ: '{"code":404,"message":"***"}'
        else if (data is String) {
          try {
            final map = jsonDecode(data);
            if (map is Map<String, dynamic>) {
              errMsg = map['message']?.toString() ?? errMsg;
            }
          } catch (_) {

          }
        }
      }
      // Ngoài khối if: mất mạng/timeout (response == null) trước đây không emit gì →
      // kẹt ở LOADING.
      logger.d(e);
      logger.d("err msg :: $errMsg");
      emit(state.copyWith(sendInvalidStatus: LoadStatus.FAILURE,errorMsg: errMsg));
    } catch (e) {
      // Lỗi khác DioException: không để trạng thái kẹt ở LOADING.
      logger.d(e);
      emit(state.copyWith(
        sendInvalidStatus: LoadStatus.FAILURE,
        errorMsg: 'Có lỗi xảy ra, vui lòng thử lại sau',
      ));
    }
  }


  void onChangeReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void onChangeStartTime(String start) {
    emit(state.copyWith(startTime: start));
  }

  void onChangeEndTime(String end) {
    emit(state.copyWith(endTime: end));
  }

  Future<void> setYearMonth(int year, int month) async {
    emit(state.copyWith(selectedYear: year,
        selectedMonth: month));
    // await getListAttendances(DateTime(year, month , 1));
  }
}
