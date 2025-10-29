import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';

import '../../core/commons/global_data.dart';
import '../../core/helper/response_mapper.dart';
import '../../core/logger/logger.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../../data/models/entities/token_entity.dart';
import '../../data/models/enums/load_status.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  UserRepository userRepository;
  AuthRepository authRepository;

  AppCubit({
    required this.authRepository,
    required this.userRepository
  }) : super(AppState());

  Future<void> changeAppLanguage(String code) async {
    try {
      await SharedPrefsHelper.setAppLanguage(code);
      emit(state.copyWith(locale: Locale(code)));
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> loadAppLanguage() async {
    final currentLang = await SharedPrefsHelper.getAppLanguage();
    emit(state.copyWith(locale: Locale(currentLang)));
  }

  void getProfile() async {
    int uId = await SharedPrefsHelper.getUserId();
    final param = {
      "user_id" : uId,
    };
    try {
      final user = await userRepository.getUserProfile(param);
      ProfileEntity? userEntity;
      if (user.data != null) {
        GlobalData.instance.userProfile =  mapObject(user.data, ProfileEntity.fromJson);
        userEntity = mapObject(user.data, ProfileEntity.fromJson);
        // getUserAvatar(userEntity?.id ?? 0);
      }
      emit(state.copyWith(userProfile: userEntity));
    } catch (error) {
      logger.e(error);
    }
  }
}