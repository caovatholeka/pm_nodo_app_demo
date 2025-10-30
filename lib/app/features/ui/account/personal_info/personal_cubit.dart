import 'package:flutter_bloc/flutter_bloc.dart';
import 'personal_state.dart';
import '../../../../data/models/entities/profile_entity.dart';
import '../../../../core/helper/response_mapper.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/commons/global_data.dart';

class PersonalCubit extends Cubit<PersonalState> {
  final UserRepository userRepository;

  PersonalCubit({required this.userRepository}) : super(const PersonalState());

  Future<void> fetchUserInfo() async {
    emit(state.copyWith(isLoading: true));

    try {
      final body = {
        "user_id": GlobalData.instance.userId,
      };

      final response = await userRepository.getUserProfile(body);

      final profile = mapObject(response.data, ProfileEntity.fromJson);

      if (profile != null) {
        emit(state.copyWith(profile: profile, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: "Không có dữ liệu người dùng"));
      }
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
