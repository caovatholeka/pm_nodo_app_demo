import 'dart:ui';

import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/entities/work_entry_type_entity.dart';
import 'package:pm_app/app/data/models/entities/work_flow_stage_entity.dart';

import '../../core/commons/global_data.dart';
import '../../core/helper/response_mapper.dart';
import '../../core/logger/logger.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../../data/models/entities/task_stage_entity.dart';
import '../../data/models/entities/token_entity.dart';
import '../../data/models/enums/load_status.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  UserRepository userRepository;
  AuthRepository authRepository;

  AppCubit({required this.authRepository, required this.userRepository})
    : super(AppState());

  Future<void> changeAppLanguage(String code) async {
    try {
      final locale = Locale(code);
      await SharedPrefsHelper.setAppLanguage(code);
      emit(state.copyWith(locale: locale));
      logger.d("Language changed to: $code");
    } catch (error) {
      logger.e("Error changing app language: $error");
    }
  }

  Future<void> loadAppLanguage() async {
    try {
      final savedLang = await SharedPrefsHelper.getAppLanguage();
      final locale = Locale(savedLang);
      emit(state.copyWith(locale: locale));
      logger.d("Loaded saved language: $savedLang");
    } catch (e) {
      logger.e("Error loading saved language: $e");
    }
  }

  Future<ProfileEntity?> getProfile({bool forceRefresh = false}) async {
    final cachedProfile = GlobalData.instance.userProfile;
    if (!forceRefresh && cachedProfile != null) {
      if (state.userProfile != cachedProfile) {
        emit(state.copyWith(userProfile: cachedProfile));
      }
      return cachedProfile;
    }

    if (GlobalData.instance.userId == null) {
      final token = await SharedPrefsHelper.getToken();
      GlobalData.instance.userId = token?.uid;
    }

    if (GlobalData.instance.userId == null) {
      logger.e("Không có user_id để gọi API getUserProfile");
      return null;
    }

    final param = {"user_id": GlobalData.instance.userId};

    try {
      final user = await userRepository.getUserProfile(param);
      if (user.data != null) {
        final userEntity = mapObject(user.data, ProfileEntity.fromJson);
        GlobalData.instance.userProfile = userEntity;
        emit(state.copyWith(userProfile: userEntity));
        return userEntity;
      }
    } catch (error) {
      logger.e(error);
    }

    return GlobalData.instance.userProfile ?? state.userProfile;
  }

  void clearSessionData() {
    emit(
      AppState(
        locale: state.locale,
        totalUnread: 0,
        isLoggedIn: false,
        tokenExpired: false,
      ),
    );
  }

  Future<void> getListWorkFlowStages() async {
    try {
      final res = await userRepository.getListWorkFlowStages();
      List<WorkFlowStageEntity>? list;
      if (res.data != null) {
        list = mapList(res.data, WorkFlowStageEntity.fromJson);
        if (list.isNotEmpty) {
          emit(state.copyWith(listWorkFlowStages: list));
        } else {
          emit(state.copyWith(listWorkFlowStages: []));
        }
      }
    } catch (e) {
      logger.d(e);
    }
  }

  Future<void> getListWorkEntryTypes() async {
    try {
      final res = await userRepository.getListWorkEntryTypes();
      List<WorkEntryTypeEntity>? list;
      if (res.data != null) {
        list = mapList(res.data, WorkEntryTypeEntity.fromJson);
        if (list.isNotEmpty) {
          emit(state.copyWith(listWorkEntryTypes: list));
        } else {
          emit(state.copyWith(listWorkEntryTypes: []));
        }
      }
    } catch (e) {
      logger.d(e);
    }
  }

  getListTaskStages() async {
    try {
      final res = await userRepository.getTaskStages();
      List<TaskStageEntity>? list;
      if (res.data != null) {
        list = mapList(res.data, TaskStageEntity.fromJson);
        emit(state.copyWith(listTaskStages: list));
      }
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(listTaskStages: []));
    }
  }

  Future<void> countUnreadNoti() async {
    try {
      final res = await userRepository.countUnreadNoti();

      if (res.code == 200) {
        final data = res.data as Map<String, dynamic>;
        final unread = (data['unread_count'] as num?)?.toInt() ?? 0;

        syncUnreadCount(unread);
      }
    } catch (e, s) {
      logger.e("countUnreadNoti error: $e");
      logger.d("stack: $s");
    }
  }

  void syncUnreadCount(int unread) {
    final normalizedUnread = unread < 0 ? 0 : unread;
    emit(state.copyWith(totalUnread: normalizedUnread));
    _syncAppBadge(normalizedUnread);
  }

  void clearUnreadNoti() {
    syncUnreadCount(0);
  }

  void _syncAppBadge(int unread) {
    try {
      FlutterAppBadge.count(unread);
    } catch (e, s) {
      logger.e("sync app badge error: $e");
      logger.d("stack: $s");
    }
  }

  void onTokenExpired() {
    emit(state.copyWith(tokenExpired: true));
  }

  void resetTokenExpired() {
    emit(state.copyWith(tokenExpired: false));
  }
}
