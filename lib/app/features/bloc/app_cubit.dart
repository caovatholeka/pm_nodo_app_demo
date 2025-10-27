import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/logger/logger.dart';
import '../../data/local/shared_prefs_helper.dart';
import '../../data/models/entities/token_entity.dart';
import '../../data/models/enums/load_status.dart';
import '../../data/repositories/auth_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AuthRepository authRepository;

  AppCubit({
    required this.authRepository,
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
}