import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/on_leave_entity.dart';

import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'detail_on_leave_state.dart';

class DetailOnLeaveCubit extends Cubit<DetailOnLeaveState> {
  OnLeaveRepository repository;

  DetailOnLeaveCubit({required this.repository}) : super(DetailOnLeaveState());

  @override
  Future<void> close() {
    return super.close();
  }

  getDetailOnLeave(){
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
  }

}