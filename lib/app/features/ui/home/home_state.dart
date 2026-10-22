part of 'home_cubit.dart';

enum AttendanceAction { checkIn, checkOut, none }

const Object _homeCheckInTodayUnset = Object();
const Object _homeCheckOutTodayUnset = Object();
const Object _homeShiftTodayUnset = Object();

class HomeState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus loadProfile;

  // trang thai cham cong hom nay
  final List<ExplanationEntity>? listAttendanceToday;

  final String? checkInToday;
  final String? checkOutToday;

  final List<TaskEntity>? listNewTasks;
  final AttendanceAction attendanceAction;
  final LoadStatus attendanceActionStatus;

  // ca được phân hôm nay (null = chưa tải / không có ca → Home dùng 08:30–18:00)
  final ShiftOfDayEntity? shiftToday;

  // trạng thái tải ca: SUCCESS + shiftToday null = đã tải xong và CHƯA ĐƯỢC PHÂN CA
  final LoadStatus shiftStatus;

  const HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.loadProfile = LoadStatus.INITIAL,
    this.listNewTasks,
    this.checkInToday,
    this.checkOutToday,
    this.attendanceAction = AttendanceAction.checkIn,
    this.attendanceActionStatus = LoadStatus.INITIAL,
    this.shiftToday,
    this.shiftStatus = LoadStatus.INITIAL,
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday,
    LoadStatus? loadDataStatus,
    LoadStatus? loadProfile,
    List<TaskEntity>? listNewTasks,
    Object? checkInToday = _homeCheckInTodayUnset,
    Object? checkOutToday = _homeCheckOutTodayUnset,
    AttendanceAction? attendanceAction,
    LoadStatus? attendanceActionStatus,
    Object? shiftToday = _homeShiftTodayUnset,
    LoadStatus? shiftStatus,
  }) {
    return HomeState(
      listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      loadProfile: loadProfile ?? this.loadProfile,
      listNewTasks: listNewTasks ?? this.listNewTasks,
      checkInToday:
          identical(checkInToday, _homeCheckInTodayUnset)
              ? this.checkInToday
              : checkInToday as String?,
      checkOutToday:
          identical(checkOutToday, _homeCheckOutTodayUnset)
              ? this.checkOutToday
              : checkOutToday as String?,
      attendanceAction: attendanceAction ?? this.attendanceAction,
      attendanceActionStatus:
          attendanceActionStatus ?? this.attendanceActionStatus,
      shiftToday:
          identical(shiftToday, _homeShiftTodayUnset)
              ? this.shiftToday
              : shiftToday as ShiftOfDayEntity?,
      shiftStatus: shiftStatus ?? this.shiftStatus,
    );
  }

  @override
  List<Object?> get props => [
    listAttendanceToday,
    loadDataStatus,
    loadProfile,
    listNewTasks,
    checkInToday,
    checkOutToday,
    attendanceAction,
    shiftToday,
    shiftStatus,
    attendanceActionStatus,
  ];
}
