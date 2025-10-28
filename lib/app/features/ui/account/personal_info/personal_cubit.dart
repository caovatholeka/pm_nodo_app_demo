import 'package:flutter_bloc/flutter_bloc.dart';
import 'personal_state.dart';

class PersonalCubit extends Cubit<PersonalState> {
  PersonalCubit() : super(const PersonalState());

  void loadPersonalData() async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      isLoading: false,
      name: "NGUYỄN MINH DŨNG",
      email: "dungnm@nodo.com",
      address: "Liền kề 22 TT03, KĐT Tây Nam Linh Đàm, Hoàng Mai, Hà Nội",
    ));
  }
}
