import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/data/repositories/work_entry_repository.dart';
import 'package:pm_app/di/di.dart';

import '../../../../../core/commons/global_data.dart';
import '../../../../../data/models/enums/load_status.dart';

part 'explanation_state.dart';

class ExplanationCubit extends Cubit<ExplanationState> {
  WorkEntryRepository repository;
  ExplanationCubit({required this.repository}) : super(ExplanationState());

  void updateReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void resetSubmitSuccess() {
  emit(state.copyWith(submitSuccess: false));
}


  // Future<void> fetchProfile() async {
  //   emit(state.copyWith(isLoading: true, error: null));
  //
  //   try {
  //     final token = await SharedPrefsHelper.getToken();
  //     final accessToken = token?.accessToken;
  //
  //     if (accessToken == null || accessToken.isEmpty) {
  //       emit(state.copyWith(isLoading: false, error: "Không có token"));
  //       return;
  //     }
  //
  //     final parts = accessToken.split('.');
  //     final payloadPart = parts[0];
  //     final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payloadPart)));
  //     final data = json.decode(decoded);
  //     final userId = data['uid'];
  //
  //     if (userId == null) {
  //       emit(state.copyWith(isLoading: false, error: "Token không hợp lệ"));
  //       return;
  //     }
  //
  //     final repo = sl<UserRepository>();
  //     final resp = await repo.getUserProfile({"user_id": userId});
  //
  //     final rawData = resp.data;
  //     final jsonData = rawData['data'] ?? rawData;
  //
  //     final profile = ProfileEntity.fromJson(Map<String, dynamic>.from(jsonData));
  //
  //     emit(state.copyWith(profile: profile, isLoading: false));
  //   } catch (e) {
  //     emit(state.copyWith(isLoading: false, error: e.toString()));
  //   }
  // }

  Future<void> getListWorkEntries() async {
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try {
      final param = {
        "limit": 20,
        "offset": 0,
        "date_from": "2025-10-01",
        "date_to": "2025-10-30"
      };
      final res = await repository.getWorkEntries(param);
      if(res.data != null){
        logger.d("resss ::: ${res.data.toString()}");
      }
    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> sendInvalidReason() async {
    emit(state.copyWith(isLoading: true, submitSuccess: false));

    try {
      final profile = state.profile;

      if (profile == null || state.reason == null || state.reason!.isEmpty) {
        emit(state.copyWith(isLoading: false, error: "Thiếu thông tin"));
        return;
      }

      final now = DateTime.now();
      final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      double startTime = now.millisecondsSinceEpoch / 1000;
      double stopTime = now.add(const Duration(hours: 8)).millisecondsSinceEpoch / 1000;

      final body = {
        "employee_id": GlobalData.instance.userProfile?.employeeId ?? 0,
        "department_id": profile.department?.id,
        "date": date,
        "date_start_employee_commit": startTime,
        "date_stop_employee_commit": stopTime,
        "note": state.reason,
      };

      await sl<ApiClient>().sendInvalid(body);

      emit(state.copyWith(
        isLoading: false,
        reason: "",
        submitSuccess: true, 
      ));

    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
