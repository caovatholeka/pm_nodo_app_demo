import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

part 'justification_state.dart';

class JustificationCubit extends Cubit<JustificationState> {
  JustificationCubit() : super(JustificationState()) {
    _initData();
  }

  void _initData() {
    emit(
      state.copyWith(
        loadStatus: LoadStatus.SUCCESS,
        listJustifications: [
          JustificationEntity(
            code: "HE2512/00009",
            date: "2026-01-05",
            type: "Cá nhân",
            creator: "Thắng",
            status: "Trưởng phòng duyệt",
            statusId: 14,
          ),
          JustificationEntity(
            code: "HE2512/00009",
            date: "2026-01-05",
            type: "Công việc",
            creator: "Thắng",
            status: "Hoàn thành",
            statusId: 11,
          ),
          JustificationEntity(
            code: "HE2512/00008",
            date: "2026-01-05",
            type: "Công việc",
            creator: "Thắng",
            status: "Hoàn thành",
            statusId: 11,
          ),
        ],
      ),
    );
  }
}
