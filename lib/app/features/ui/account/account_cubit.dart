import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/di/di.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../../data/repositories/user_repository.dart';
import '../../bloc/app_cubit.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final UserRepository userRepository;

  AccountCubit(this.userRepository) : super(const AccountState());

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
        emit(state.copyWith(
          loadStatus: LoadStatus.SUCCESS,
          profile: profile,
        ));
      } else {
        emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
      }
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }
  }
}
