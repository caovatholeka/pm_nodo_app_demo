import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

part 'justification_detail_state.dart';

class JustificationDetailCubit extends Cubit<JustificationDetailState> {
  JustificationDetailCubit() : super(const JustificationDetailState());

  Future<void> getDetail(int id) async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    await Future.delayed(const Duration(milliseconds: 300));

    emit(
      state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        detail: JustificationEntity(
          code: "HE2512/00009",
          date: "2026-01-05",
          type: "Nghỉ có lương",
          creator: "tét",
          status: "Nháp",
          statusId: 1,
          employeeName: "Tét",
          departmentName: "Phòng sản xuất",
          fromDate: "05/01/2026",
          toDate: "07/01/2026",
          reason: "Việc cá nhân",
          approver: "Tạ Quang Mạnh",
          follower: "Trần Xuân Trường",
        ),
      ),
    );
  }
}
