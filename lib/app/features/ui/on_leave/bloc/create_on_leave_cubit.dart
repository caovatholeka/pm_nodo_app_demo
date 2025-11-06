import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/leave_day_entity.dart';

import '../../../../config/app_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/master_data_item.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/models/param/create_leave_param.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'create_on_leave_state.dart';

class CreateOnLeaveCubit extends Cubit<CreateOnLeaveState> {
  OnLeaveRepository repository;

  CreateOnLeaveCubit({required this.repository}) : super(CreateOnLeaveState());

  // @override
  // Future<void> close() {
  //   return super.close();
  // }

  void createOrUpdateLeaveDay() async{
    emit(state.copyWith(createStatus: LoadStatus.LOADING));
    try{
      final UpdateOnLeaveParam param = UpdateOnLeaveParam(
        employeeId: 57,
        holidayStatusId: 1,
        departmentId: 4,
        requestDateFrom: AppUtil().parseDateToYMD(state.fromDate),
        requestDateTo: AppUtil().parseDateToYMD(state.toDate),
        name: state.reason,
        leaveDays: state.listLeaveDays
      );
      final res = await repository.saveOrUpdateHrLeave(param);
      if((res.lines ?? []).isNotEmpty){
        emit(state.copyWith(createStatus: LoadStatus.SUCCESS));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(createStatus: LoadStatus.FAILURE));
    }
  }

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
      MasterDataItem(text: "Cả ngày",code: "full"),
      MasterDataItem(text: "Sáng",code: "before"),
      MasterDataItem(text: "Chiều",code: "after"),
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