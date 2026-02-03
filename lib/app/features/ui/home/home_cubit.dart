import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';

import '../../../core/commons/global_data.dart';
import '../../../core/helper/response_mapper.dart';
import '../../../core/logger/logger.dart';
import '../../../data/local/shared_prefs_helper.dart';
import '../../../data/models/entities/explanation_entity.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/entities/task_data_entity.dart';
import '../../../data/repositories/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  UserRepository userRepository;
  TaskRepository taskRepository;

  HomeCubit({required this.userRepository, required this.taskRepository}) : super(HomeState());

  Future<void> getListAttendanceToday() async {
    final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());

    try {
      final res = await userRepository.getListAttendanceToday(
        todayStr,
        todayStr,
      );

      List<ExplanationEntity> list = [];

      if (res.data != null) {
        list = mapList(res.data, ExplanationEntity.fromJson);
      }

      // Lọc đúng ngày hôm nay
      final todayList = list.where((e) => e.date == todayStr).toList();

      if (todayList.isEmpty) {
        emit(
          state.copyWith(
            listAttendanceToday: [],
            checkInToday: null,
            checkOutToday: null,
            attendanceAction: AttendanceAction.checkIn,
          ),
        );
        return;
      }

      todayList.sort(
        (a, b) =>
            DateTime.parse(a.datetime!).compareTo(DateTime.parse(b.datetime!)),
      );

      String? checkIn;
      String? checkOut;

      for (final e in todayList) {
        if (e.action == 'check_in') {
          checkIn = e.datetime;
        } else if (e.action == 'check_out') {
          checkOut = e.datetime;
        }
      }

      AttendanceAction action;
      if (checkIn == null) {
        action = AttendanceAction.checkIn;
      } else if (checkOut == null) {
        action = AttendanceAction.checkOut;
      } else {
        action = AttendanceAction.none;
      }

      emit(
        state.copyWith(
          listAttendanceToday: todayList,
          checkInToday: checkIn,
          checkOutToday: checkOut,
          attendanceAction: action,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.e(s);

      // Lỗi → coi như chưa chấm gì
      emit(
        state.copyWith(
          listAttendanceToday: [],
          checkInToday: null,
          checkOutToday: null,
          attendanceAction: AttendanceAction.checkIn,
        ),
      );
    }
  }

  Future<void> getProfile() async {
    emit(state.copyWith(loadProfile: LoadStatus.LOADING));
    if (GlobalData.instance.userId == null) {
      final token = await SharedPrefsHelper.getToken();
      GlobalData.instance.userId = token?.uid;
    }

    if (GlobalData.instance.userId == null) {
      logger.e("Không có user_id để gọi API getUserProfile");
      return;
    }

    final param = {"user_id": GlobalData.instance.userId};

    try {
      final user = await userRepository.getUserProfile(param);
      if (user.data != null) {
        final userEntity = mapObject(user.data, ProfileEntity.fromJson);
        GlobalData.instance.userProfile = userEntity;
        // emit(state.copyWith(userProfile: userEntity));
        emit(state.copyWith(loadProfile: LoadStatus.SUCCESS));
      }
    } catch (error) {
      logger.e(error);
      emit(state.copyWith(loadProfile: LoadStatus.FAILURE));
    }
  }

  // lấy danh sách việc cần làm
  getListNewTasks() async {
    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));
    String? name;
    int stagId = 1;
    int page = 1;
    int limit = 5;
    try {
      final res = await taskRepository.getListTask(name, stagId, page, limit);
      TaskDataEntity? taskData;
      if (res.data != null) {
        taskData = mapObject(res.data, TaskDataEntity.fromJson);
      }

      if ((taskData?.items ?? []).isNotEmpty) {
        emit(
          state.copyWith(
            loadDataStatus: LoadStatus.SUCCESS,
            listNewTasks: taskData?.items ?? [],
          ),
        );
      } else {
        emit(
          state.copyWith(loadDataStatus: LoadStatus.FAILURE, listNewTasks: []),
        );
      }
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      emit(
        state.copyWith(loadDataStatus: LoadStatus.FAILURE, listNewTasks: []),
      );
    }
  }
  

  
}
