part of 'home_cubit.dart';

class HomeState extends Equatable {
  final LoadStatus loadDataStatus;

  // trang thai cham cong hom nay
  List<ExplanationEntity>? listAttendanceToday;

  final String? checkInToday;
  final String? checkOutToday;

  List<TaskEntity>? listNewTasks;

  HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.listNewTasks,
    this.checkInToday,
    this.checkOutToday,
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday,
    LoadStatus? loadDataStatus,
    List<TaskEntity>? listNewTasks,
    String? checkInToday,
    String? checkOutToday,
  }) {
    return HomeState(
      listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      listNewTasks: listNewTasks ?? this.listNewTasks,
      checkInToday: checkInToday ?? this.checkInToday,
      checkOutToday: checkOutToday ?? this.checkOutToday
    );
  }

  @override
  List<Object?> get props => [
    listAttendanceToday,
    loadDataStatus,
    listNewTasks,
    checkInToday,
    checkOutToday
  ];
}
