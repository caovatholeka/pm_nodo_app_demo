import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';

part 'justification_state.dart';

class JustificationCubit extends Cubit<JustificationState> {
  final JutificationRepository _repo = GetIt.I<JutificationRepository>();

  JustificationCubit() : super(const JustificationState());

Future<void> loadList() async {
  emit(state.copyWith(loadStatus: LoadStatus.LOADING));
  try {
    final res = await _repo.getAttendanceList();
    
    List listJson = [];
    if (res.data is Map && res.data.containsKey('data')) {
      listJson = res.data['data'];
    } else if (res.data is List) {
      listJson = res.data;
    }

    final list = listJson
        .map((e) => JustificationEntity.fromJson(e))
        .toList();

    emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, list: list));
  } catch (e) {
    print("Mapping Error: $e"); 
    emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
  }
}
}
