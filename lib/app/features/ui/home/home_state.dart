part of 'home_cubit.dart';

class HomeState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus loadProfile;

  // trang thai cham cong hom nay
  List<ExplanationEntity>? listAttendanceToday;

  final String? checkInToday;
  final String? checkOutToday;

  List<TaskEntity>? listNewTasks;

  HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.loadProfile = LoadStatus.INITIAL,
    this.listNewTasks,
    this.checkInToday,
    this.checkOutToday,
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday,
    LoadStatus? loadDataStatus,
    LoadStatus? loadProfile,
    List<TaskEntity>? listNewTasks,
    String? checkInToday,
    String? checkOutToday,
  }) {
    return HomeState(
      listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      loadProfile: loadProfile ?? this.loadProfile,
      listNewTasks: listNewTasks ?? this.listNewTasks,
      checkInToday: checkInToday ?? this.checkInToday,
      checkOutToday: checkOutToday ?? this.checkOutToday
    );
  }

  @override
  List<Object?> get props => [
    listAttendanceToday,
    loadDataStatus,
    loadProfile,
    listNewTasks,
    checkInToday,
    checkOutToday
  ];
}
