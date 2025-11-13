import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/data/repositories/attendance_repository.dart';
import '../../../data/models/entities/attendance_entity.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/enums/load_status.dart';

part 'attendence_data_state.dart';

class AttendanceDataCubit extends Cubit<AttendanceDataState> {
  AttendanceRepository repository;

  AttendanceDataCubit({required this.repository}) : super(AttendanceDataState());


  Future<void> getListAttendances(DateTime anyMonth) async{
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try{
      // employee_id=9&month=10&year=2025
      final res = await repository.getListAttendances(9, anyMonth.month, anyMonth.year);
      final map = <DateTime, String>{};
      final mapEntries = <DateTime, List<WorkEntity>>{};

      String priorityPick(String current, String incoming) {
        // ưu tiên: C (no check-in) > MS (late/soon) > X (on time) > CT/others
        // không chấm công > đi muộn / về sớm > đúng giờ
        int rank(String v) {
          switch (v) {
            case 'C': return 3;
            case 'MS': return 2;
            case 'X': return 1;
            default: return 0;
          }
        }
        return (rank(incoming) >= rank(current)) ? incoming : current;
      }


      if(res != null && res.isNotEmpty){
        for (AttendanceEntity wd in res) {
          String code = '';
          for (WorkEntity e in wd.workEntries ?? []) {
            final d = (e.workEntryType?.code ?? '').toUpperCase();
            code = code.isEmpty ? d : priorityPick(code, d);
          }
          final dFormat = DateFormat("yyyy-MM-dd").parse(wd.date ?? "");
          final key = DateTime(dFormat.year, dFormat.month, dFormat.day);
          map[key] = code;
          mapEntries[key] = wd.workEntries ?? [];
        }

        emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listAttendances: res,
            attendanceDateMap: map,entriesByDate: mapEntries));
      }else{
        emit(state.copyWith(loadStatus: LoadStatus.SUCCESS,listAttendances: [],
            attendanceDateMap: {},entriesByDate: {}));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  onChangeSelectedEntries(List<WorkEntity>? list){
    emit(state.copyWith(listSelectedEntries: list));
  }
  onChangeSelectedDateTime(String date){
    emit(state.copyWith(selectedDateTime: date));
  }

  onChangeSelectedDate(DateTime date){
    emit(state.copyWith(selectedDate: date));
  }

  Future<void> nextMonth() async {
    final m = state.focusedMonth;
    await getListAttendances(DateTime(m?.year ?? DateTime.now().year,
        (m?.month ?? DateTime.now().month) + 1, 1));
  }

  Future<void> prevMonth() async {
    final m = state.focusedMonth;
    await getListAttendances(DateTime(m?.year ?? DateTime.now().year,
        (m?.month ?? DateTime.now().month) - 1, 1));
  }

  Future<void> setYearMonth(int year, int month) async {
    emit(state.copyWith(selectedYear: year.toString(),
        selectedMonth: month.toString(), focusedMonth:DateTime(year,month,1)));
    await getListAttendances(DateTime(year, month , 1));
  }
}