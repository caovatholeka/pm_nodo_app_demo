import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/checkpoint_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/checkpoint_repository.dart';

part 'checkpoint_state.dart';

class CheckpointCubit extends Cubit<CheckpointState> {
  final CheckpointRepository repository;

  CheckpointCubit({required this.repository}) : super(const CheckpointState());

  Future<void> getListCheckpoint({String? dateFrom, String? dateTo}) async {
    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));

    try {
      final res = await repository.getListCheckpoint(
        _toApiDate(dateFrom),
        _toApiDate(dateTo),
      );

      final listCheckpoint = mapList<CheckpointEntity>(
        _listSource(res.data, res.items),
        CheckpointEntity.fromJson,
      );

      emit(
        state.copyWith(
          loadDataStatus: LoadStatus.SUCCESS,
          listCheckpoint: listCheckpoint,
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);

      emit(
        state.copyWith(
          loadDataStatus: LoadStatus.FAILURE,
          listCheckpoint: const [],
          error: e.toString(),
        ),
      );
    }
  }

  void onChangeDateFilter(String start, String end) {
    emit(state.copyWith(startDateFilter: start, endDateFilter: end));
  }

  Future<void> submitCheckpoint(int id) async {
    if (id == 0) return;

    emit(state.copyWith(loadSubmitStatus: LoadStatus.LOADING));
    try {
      await repository.submitCheckpoint(id);
      emit(state.copyWith(loadSubmitStatus: LoadStatus.SUCCESS));
    } catch (e, s) {
      logger.d(e);
      logger.d(s);

      emit(
        state.copyWith(
          loadSubmitStatus: LoadStatus.FAILURE,
          error: e.toString(),
        ),
      );
    }
  }

  void resetSubmitStatus() {
    emit(state.copyWith(loadSubmitStatus: LoadStatus.INITIAL));
  }

  String? _toApiDate(String? value) {
    if (value == null || value.isEmpty) return value;

    try {
      return DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parseStrict(value));
    } catch (_) {
      return value;
    }
  }

  dynamic _listSource(dynamic data, dynamic items) {
    if (data is List) return data;
    if (items is List) return items;
    if (data is Map) {
      return data['items'] ?? data['data'];
    }
    return data ?? items;
  }
}
