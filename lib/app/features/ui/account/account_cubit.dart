import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/di/di.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../../data/repositories/user_repository.dart';
import '../../bloc/app_cubit.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final UserRepository userRepository;

  AccountCubit(this.userRepository) : super(const AccountState());

  void onResetStatus() {
    emit(
      state.copyWith(
        loadStatus: LoadStatus.INITIAL,
        logoutStatus: LoadStatus.INITIAL,
      ),
    );
  }

  Future<void> fetchUserProfile() async {
    try {
      emit(state.copyWith(loadStatus: LoadStatus.LOADING));

      final appCubit = sl<AppCubit>();
      final userId = appCubit.state.userProfile?.id;

      if (userId == null) {
        emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
        return;
      }

      final response = await userRepository.getUserProfile({'user_id': userId});

      if (response.data != null) {
        final profile = ProfileEntity.fromJson(response.data);
        emit(state.copyWith(loadStatus: LoadStatus.SUCCESS, profile: profile));
      } else {
        emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
      }
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(logoutStatus: LoadStatus.LOADING));

    try {
      await _notifyServerLogout();
      await _clearLocalSession();
      emit(state.copyWith(logoutStatus: LoadStatus.SUCCESS));
    } catch (e) {
      logger.d(e);
      emit(state.copyWith(logoutStatus: LoadStatus.FAILURE));
    }
  }

  Future<void> _notifyServerLogout() async {
    try {
      final deviceType = await SharedPrefsHelper.getDeviceType();
      await userRepository.logOut({"device_type": deviceType});
    } catch (e) {
      // Logout local should still continue even if the server call fails.
      logger.d(e);
    }
  }

  Future<void> _clearLocalSession() async {
    await SharedPrefsHelper.saveToken(null);
    await SharedPrefsHelper.setIsLoginApp(false);

    final globalData = GlobalData.instance;
    globalData.token = null;
    globalData.userId = null;
    globalData.userProfile = null;
    globalData.bottomNavIndex.value = 0;

    sl<AppCubit>().clearSessionData();
  }
}
