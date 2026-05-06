import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/evaluation_repository.dart';

part 'create_apprasial_state.dart';

class CreateApprasialCubit extends Cubit<CreateApprasialState> {
  final EvaluationRepository repository;

  CreateApprasialCubit({required this.repository})
    : super(const CreateApprasialState());

  Future<void> createEvaluation(EvaluationEntity body) async {
    emit(
      state.copyWith(loadDataStatus: LoadStatus.LOADING, errorMessage: null),
    );

    try {
      final res = await repository.createEvaluation(body);

      emit(
        state.copyWith(
          loadDataStatus:
              res.error == true ? LoadStatus.FAILURE : LoadStatus.SUCCESS,
          errorMessage: res.message,
        ),
      );
    } on DioException catch (e, s) {
      logger.d(e);
      logger.d(s);

      emit(
        state.copyWith(
          loadDataStatus: LoadStatus.FAILURE,
          errorMessage: _dioErrorMessage(e),
        ),
      );
    } catch (e, s) {
      logger.d(e);
      logger.d(s);

      emit(
        state.copyWith(
          loadDataStatus: LoadStatus.FAILURE,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void resetStatus() {
    emit(
      state.copyWith(loadDataStatus: LoadStatus.INITIAL, errorMessage: null),
    );
  }

  void clearErrorMessage() {
    emit(state.copyWith(errorMessage: null));
  }

  String _dioErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return error.message ?? error.toString();
  }
}
