part of 'home_cubit.dart';

enum AttendanceAction { checkIn, checkOut, none }

const Object _homeCheckInTodayUnset = Object();
const Object _homeCheckOutTodayUnset = Object();

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

  const HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.loadProfile = LoadStatus.INITIAL,
    this.listNewTasks,
    this.checkInToday,
    this.checkOutToday,
    this.attendanceAction = AttendanceAction.checkIn,
    this.attendanceActionStatus = LoadStatus.INITIAL,
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
    attendanceActionStatus,
  ];
}
