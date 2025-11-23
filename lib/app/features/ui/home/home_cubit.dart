import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/response_mapper.dart';
import '../../../core/logger/logger.dart';
import '../../../data/models/entities/explanation_entity.dart';
import '../../../data/repositories/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  UserRepository userRepository;

  HomeCubit({
    required this.userRepository
  }) : super(HomeState());

  // lấy lịch sử chấm công ngày hôm nay
  getListAttendanceToday() async {
    final year = DateTime.now().year;
    final month = DateTime.now().month;
    final day = DateTime.now().day;
    final dateFrom = "$year-$month-$day";
    try{
      final res = await userRepository.getListAttendanceToday(dateFrom,dateFrom);
      List<ExplanationEntity>? list;
      if(res.data != null){
        list =  mapList(res.data, ExplanationEntity.fromJson);
      }

      if((list ?? []).isNotEmpty){
        emit(state.copyWith(listAttendanceToday: list));
      }else{
        emit(state.copyWith(listAttendanceToday: []));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(listAttendanceToday: []));
    }
  }

}