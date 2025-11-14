import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';

part 'explanation_list_state.dart';

class ExplanationListCubit extends Cubit<ExplanationListState> {
  WorkEntryRepository repository;

  ExplanationListCubit({required this.repository}) : super(ExplanationListState());

  void initData() async{
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try{
      logger.d("start call api entry ::");
      final body = {
        "limit": 20,
        "offset": 0,
        "date_from": "2025-09-01",
        "date_to": "2025-09-30"
      };
      logger.d("boddy ::: $body");
      final res = await repository.getWorkEntries(body);

      logger.d("resss ::: ${res.toJson()}");
    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> loadWorkEntries() async {

   // emit(state.copyWith(loadStatus: LoadStatus.LOADING));

    try {
      logger.d("start call api entry ::");
      final body = {
        "limit": 20,
        "offset": 0,
        "date_from": "2025-09-01",
        "date_to": "2025-09-30"
      };
      logger.d("boddy ::: $body");

      final response = await repository.getWorkEntries(body);
      logger.d("response ::: $response");
      List<WorkEntryEntity>? list;
      if(response.data != null){
        list = mapList(response.data, WorkEntryEntity.fromJson);
      }
      if((list ?? []).isNotEmpty){
        emit(state.copyWith( list: list));
      }else{
        emit(state.copyWith(list: []));
      }

      // if (response.code != 200) {
      //   emit(state.copyWith(isLoading: false, error: response.message));
      //   return;
      // }
      // if (response.data == null) {
      //   emit(state.copyWith(isLoading: false, list: []));
      //   return;
      // }
      //
      // final raw = response.data["data"] as List<dynamic>? ?? [];
      //
      // final list = raw
      //     .map((e) => WorkEntryEntity.fromJson(Map<String, dynamic>.from(e)))
      //     .toList();
      //
      // emit(state.copyWith(isLoading: false, list: list));
    } catch (e,s) {
      logger.d("err : $e");
      logger.d("seess :: $s");
      emit(state.copyWith( error: e.toString()));
    }
  }
}
