import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/features/ui/auth/otp_confirm/otp_verify_cubit.dart';
import 'package:rename/platform_file_editors/abs_platform_file_editor.dart';

part 'overtime_state.dart';

class OvertimeCubit extends Cubit<OvertimeState> {
  final OvertimeRepository _repo = GetIt.I<OvertimeRepository>();

  OvertimeCubit() : super(const OvertimeState());

  Future<void> loadOTList() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final res = await _repo.getListOT();
      List listJson = [];
      if (res.data is Map && res.data.containsKey('data')) {
        listJson = res.data['data'];
      } else if (res.data is List) {
        listJson = res.data;
      }

      final list = listJson
        .map((e) => OvertimeEntity.fromJson(e))
        .toList();

      emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, list: list));
    } catch (e, s) {
      logger.e("err: $e");
      logger.d("where: $s");
      
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE, error: e.toString()));
    }
  }
}
