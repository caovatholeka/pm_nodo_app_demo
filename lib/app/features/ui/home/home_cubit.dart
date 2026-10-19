import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/check_in_out_entity.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/task_repository.dart';

import '../../../core/commons/global_data.dart';
import '../../../core/helper/response_mapper.dart';
import '../../../core/logger/logger.dart';
import '../../../data/local/shared_prefs_helper.dart';
import '../../../data/models/entities/explanation_entity.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/entities/shift_of_day_entity.dart';
import '../../../data/models/entities/task_data_entity.dart';
import '../../../data/repositories/user_repository.dart';

part 'home_state.dart';

class _AttendanceTodayData {
  final List<ExplanationEntity> listAttendanceToday;
  final String? checkInToday;
  final String? checkOutToday;
  final AttendanceAction attendanceAction;

  const _AttendanceTodayData({
    required this.listAttendanceToday,
    required this.checkInToday,
    required this.checkOutToday,
    required this.attendanceAction,
  });
}

class HomeCubit extends Cubit<HomeState> {
  UserRepository userRepository;
  TaskRepository taskRepository;

  HomeCubit({required this.userRepository, required this.taskRepository})
    : super(HomeState());

  Future<void> getListAttendanceToday() async {
    try {
      final data = await _fetchAttendanceTodayData();
      _emitAttendanceData(data);
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
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

  /// Ca được phân hôm nay (giờ vào/ra ca ở Home). Lỗi mạng thì giữ giá trị cũ; Home tự
  /// dùng 08:30–18:00 khi chưa có ca.
  Future<void> getShiftToday() async {
    final today = DateTime.now();
    try {
      final res = await userRepository.getShiftAsDay(
        DateFormat("yyyy-MM-dd").format(today),
      );
      if (isClosed) return;
      emit(state.copyWith(shiftToday: ShiftOfDayEntity.fromApiData(res.data, today)));
    } catch (e) {
      logger.w('Load shift of day failed: $e');
    }
  }

  Future<void> handleAttendanceSubmitted(CheckInOutEntity attendance) async {
    final action = (attendance.action ?? '').trim().toLowerCase();
    if ((attendance.datetime ?? '').trim().isEmpty) {
      await getListAttendanceToday();
      return;
    }
    // Hiển thị tạm theo giờ máy: server cũ trả `datetime` theo UTC (lệch 7 tiếng) nên
    // không dùng trực tiếp; giờ chính thức thay vào ngay khi đồng bộ xong.
    final submittedAt = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    final optimisticList = List<ExplanationEntity>.from(
      state.listAttendanceToday ?? const <ExplanationEntity>[],
    );

    final optimisticEntity = ExplanationEntity(
      date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
      action: action,
      datetime: submittedAt,
    );

    final existingIndex = optimisticList.indexWhere(
      (item) => (item.action ?? '').trim().toLowerCase() == action,
    );

    if (existingIndex >= 0) {
      optimisticList[existingIndex] = optimisticEntity;
    } else {
      optimisticList.add(optimisticEntity);
    }

    optimisticList.sort((a, b) {
      final aDate = AppDateUtils.parseFlexibleDate(a.datetime);
      final bDate = AppDateUtils.parseFlexibleDate(b.datetime);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return -1;
      if (bDate == null) return 1;
      return aDate.compareTo(bDate);
    });

    emit(
      state.copyWith(
        listAttendanceToday: optimisticList,
        checkInToday:
            _isCheckInAction(action) ? submittedAt : state.checkInToday,
        checkOutToday:
            _isCheckOutAction(action) ? submittedAt : state.checkOutToday,
        attendanceAction:
            _isCheckInAction(action)
                ? AttendanceAction.checkOut
                : AttendanceAction.none,
      ),
    );

    // Đồng bộ chạy nền, KHÔNG phủ loading lên Home (trước đây khoá màn hình trong lúc
    // gọi lại lịch sử tối đa 6 lần). Lượt chấm đã commit trước khi API trả về nên
    // thường khớp ngay lần đầu; thử lại tối đa 3 lần phòng mạng chập chờn.
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final data = await _fetchAttendanceTodayData();
        if (isClosed) return;
        if (_matchesAttendance(data, attendance)) {
          _emitAttendanceData(data);
          return;
        }
      } catch (e, s) {
        logger.e(e);
        logger.e(s);
      }
      if (attempt < 2) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    logger.w('Attendance ${attendance.id} not found in today history, keep local time');
  }

  void resetAttendanceActionStatus() {
    emit(state.copyWith(attendanceActionStatus: LoadStatus.INITIAL));
  }

  Future<void> getProfile() async {
    emit(state.copyWith(loadProfile: LoadStatus.LOADING));
    if (GlobalData.instance.userId == null) {
      final token = await SharedPrefsHelper.getToken();
      GlobalData.instance.userId = token?.uid;
    }

    if (GlobalData.instance.userId == null) {
      logger.e("KhÃ´ng cÃ³ user_id Ä‘á»ƒ gá»i API getUserProfile");
      return;
    }

    final param = {"user_id": GlobalData.instance.userId};

    try {
      final user = await userRepository.getUserProfile(param);
      if (user.data != null) {
        final userEntity = mapObject(user.data, ProfileEntity.fromJson);
        GlobalData.instance.userProfile = userEntity;
        emit(state.copyWith(loadProfile: LoadStatus.SUCCESS));
      }
    } catch (error) {
      logger.e(error);
      emit(state.copyWith(loadProfile: LoadStatus.FAILURE));
    }
  }

  Future<void> getListNewTasks() async {
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

  Future<_AttendanceTodayData> _fetchAttendanceTodayData() async {
    final todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final res = await userRepository.getListAttendanceToday(todayStr, todayStr);

    List<ExplanationEntity> list = [];
    if (res.data != null) {
      list = mapList(res.data, ExplanationEntity.fromJson);
    }

    final todayList = list.where((e) => e.date == todayStr).toList();

    if (todayList.isEmpty) {
      return const _AttendanceTodayData(
        listAttendanceToday: [],
        checkInToday: null,
        checkOutToday: null,
        attendanceAction: AttendanceAction.checkIn,
      );
    }

    todayList.sort((a, b) {
      final aDate = AppDateUtils.parseFlexibleDate(a.datetime);
      final bDate = AppDateUtils.parseFlexibleDate(b.datetime);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return -1;
      if (bDate == null) return 1;
      return aDate.compareTo(bDate);
    });

    String? checkIn;
    String? checkOut;

    for (final e in todayList) {
      if (_isCheckInAction(e.action)) {
        checkIn = e.datetime;
      } else if (_isCheckOutAction(e.action)) {
        checkOut = e.datetime;
      }
    }

    final action =
        checkIn == null
            ? AttendanceAction.checkIn
            : checkOut == null
            ? AttendanceAction.checkOut
            : AttendanceAction.none;

    return _AttendanceTodayData(
      listAttendanceToday: todayList,
      checkInToday: checkIn,
      checkOutToday: checkOut,
      attendanceAction: action,
    );
  }

  void _emitAttendanceData(
    _AttendanceTodayData data, {
    LoadStatus? attendanceActionStatus,
  }) {
    emit(
      state.copyWith(
        listAttendanceToday: data.listAttendanceToday,
        checkInToday: data.checkInToday,
        checkOutToday: data.checkOutToday,
        attendanceAction: data.attendanceAction,
        attendanceActionStatus:
            attendanceActionStatus ?? state.attendanceActionStatus,
      ),
    );
  }

  bool _matchesAttendance(
    _AttendanceTodayData data,
    CheckInOutEntity attendance,
  ) {
    // Khớp theo id lượt chấm: không phụ thuộc định dạng / múi giờ của `datetime`
    // (server cũ trả UTC ở API chấm công nhưng giờ địa phương ở API lịch sử).
    if (attendance.id != null &&
        data.listAttendanceToday.any((e) => e.id == attendance.id)) {
      return true;
    }

    final action = (attendance.action ?? '').trim().toLowerCase();
    final submittedAt = attendance.datetime;

    if (_isCheckInAction(action)) {
      return _sameMoment(data.checkInToday, submittedAt);
    }

    if (_isCheckOutAction(action)) {
      return _sameMoment(data.checkOutToday, submittedAt);
    }

    return _sameMoment(data.checkInToday, submittedAt) ||
        _sameMoment(data.checkOutToday, submittedAt);
  }

  bool _sameMoment(String? left, String? right) {
    if ((left ?? '').trim().isEmpty || (right ?? '').trim().isEmpty) {
      return false;
    }

    final leftDate = AppDateUtils.parseFlexibleDate(left);
    final rightDate = AppDateUtils.parseFlexibleDate(right);

    if (leftDate != null && rightDate != null) {
      return leftDate.difference(rightDate).inSeconds.abs() <= 1;
    }

    return left == right;
  }

  bool _isCheckInAction(String? action) {
    final normalized = (action ?? '').trim().toLowerCase();
    return normalized == 'check_in' || normalized == 'checkin';
  }

  bool _isCheckOutAction(String? action) {
    final normalized = (action ?? '').trim().toLowerCase();
    return normalized == 'check_out' || normalized == 'checkout';
  }
}
