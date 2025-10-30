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
  if (GlobalData.instance.userId == null) {
    final token = await SharedPrefsHelper.getToken();
    GlobalData.instance.userId = token?.uid;
  }

  if (GlobalData.instance.userId == null) {
    logger.e("Không có user_id để gọi API getUserProfile");
    return;
  }

  final param = {
    "user_id": GlobalData.instance.userId,
  };

  try {
    final user = await userRepository.getUserProfile(param);
    if (user.data != null) {
      final userEntity = mapObject(user.data, ProfileEntity.fromJson);
      GlobalData.instance.userProfile = userEntity;
      emit(state.copyWith(userProfile: userEntity));
    }
  } catch (error) {
    logger.e(error);
  }
}

}