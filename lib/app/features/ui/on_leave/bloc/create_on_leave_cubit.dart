import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/features/ui/on_leave/data/leave_day_entity.dart';

import '../../../../config/app_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/master_data_item.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'create_on_leave_state.dart';

class CreateOnLeaveCubit extends Cubit<CreateOnLeaveState> {
  OnLeaveRepository repository;

  CreateOnLeaveCubit({required this.repository}) : super(CreateOnLeaveState());

  // @override
  // Future<void> close() {
  //   return super.close();
  // }

  // Loại ngày nghỉ
  void getListDateTypeLeaves(){
    List<MasterDataItem> list = [
      MasterDataItem(text: "Nghỉ phép",code: "P"),
      MasterDataItem(text: "Nghỉ không lương",code: "KL"),
    ];

    emit(state.copyWith(listDateTypeLeaves: list));
  }
  void onChangeDateTypeLeaves(MasterDataItem item){
    emit(state.copyWith(currentDateLeaveType: item,leaveDateType: item.text));
  }

  // Loại nghỉ
  void getListTypeLeaves(){
    List<MasterDataItem> list = [
      MasterDataItem(text: "Cả ngày",code: "ALL"),
      MasterDataItem(text: "Sáng",code: "AM"),
      MasterDataItem(text: "Chiều",code: "PM"),
    ];

    emit(state.copyWith(listTypeLeaves: list));
  }
  void onChangeLeaveType(MasterDataItem item){
    emit(state.copyWith(currentLeaveType: item,leaveType: item.text));
  }

  void onChangeListLeaveDays(List<LeaveDayEntity> list) async{
    emit(state.copyWith(listLeaveDays: []));
    emit(state.copyWith(listLeaveDays: list));
  }
  // date time
  void getNowTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppConfig.dateTimeFormat).format(now);
    emit(state.copyWith(fromDate: formattedDate, fromDateTime: now));
  }

  void setFromDate(DateTime dateTime) {
    String formattedDate = DateFormat(AppConfig.iso8601Format).format(dateTime.toUtc());
    emit(state.copyWith(fromDate: AppDateUtils.changeIso8601StringToDateTimeString(formattedDate), fromDateTime: dateTime));
  }

  void onChangeFromDate(String fromDate){
    emit(state.copyWith(fromDate: fromDate));
  }

  void setToDate(DateTime dateTime) {
    String formattedDate = DateFormat(AppConfig.iso8601Format).format(dateTime.toUtc());
    emit(state.copyWith(toDate: AppDateUtils.changeIso8601StringToDateTimeString(formattedDate), toDateTime: dateTime));
  }

  void onChangeToDate(String toDate){
    emit(state.copyWith(toDate: toDate));
  }

  void onChangeLeaveDays(String leaveDays){
    emit(state.copyWith(leaveDays: leaveDays));
  }

  void onChangeReason(String reason){
    emit(state.copyWith(reason: reason));
  }
}