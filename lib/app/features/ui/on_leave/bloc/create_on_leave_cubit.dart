import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_config.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'create_on_leave_state.dart';

class CreateOnLeaveCubit extends Cubit<CreateOnLeaveState> {
  OnLeaveRepository repository;

  CreateOnLeaveCubit({required this.repository}) : super(CreateOnLeaveState());

  @override
  Future<void> close() {
    return super.close();
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

  void onChangeLeaveType(String type){
    emit(state.copyWith(leaveType: type));
  }

  void onChangeLeaveDays(String leaveDays){
    emit(state.copyWith(leaveDays: leaveDays));
  }

  void onChangeReason(String reason){
    emit(state.copyWith(reason: reason));
  }
}