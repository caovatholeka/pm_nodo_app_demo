part of 'home_cubit.dart';

enum AttendanceAction {
  checkIn,
  checkOut,
  none,
}



class HomeState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus loadProfile;

  // trang thai cham cong hom nay
  List<ExplanationEntity>? listAttendanceToday;

  final String? checkInToday;
  final String? checkOutToday;

  List<TaskEntity>? listNewTasks;
  final AttendanceAction attendanceAction;
  final LoadStatus attendanceActionStatus;

  HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.loadProfile = LoadStatus.INITIAL,
    this.listNewTasks,
    this.checkInToday,
    this.checkOutToday,
    this.attendanceAction = AttendanceAction.checkIn,
    this.attendanceActionStatus = LoadStatus.INITIAL
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday,
    LoadStatus? loadDataStatus,
    LoadStatus? loadProfile,
    List<TaskEntity>? listNewTasks,
    String? checkInToday,
    String? checkOutToday,
    AttendanceAction? attendanceAction,
    LoadStatus? attendanceActionStatus,
  }) {
    return HomeState(
      listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      loadProfile: loadProfile ?? this.loadProfile,
      listNewTasks: listNewTasks ?? this.listNewTasks,
      checkInToday: checkInToday ?? this.checkInToday,
      checkOutToday: checkOutToday ?? this.checkOutToday,
      attendanceAction: attendanceAction ?? this.attendanceAction,
      attendanceActionStatus: attendanceActionStatus ?? this.attendanceActionStatus,
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


