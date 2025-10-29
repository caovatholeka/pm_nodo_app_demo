import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/entities/on_leave_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/on_leave_repository.dart';

part 'on_leave_state.dart';

class OnLeaveCubit extends Cubit<OnLeaveState> {
  OnLeaveRepository repository;

  OnLeaveCubit({required this.repository}) : super(OnLeaveState());


}