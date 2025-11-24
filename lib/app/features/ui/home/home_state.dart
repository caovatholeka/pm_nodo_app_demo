part of 'home_cubit.dart';

class HomeState extends Equatable {
  final LoadStatus loadDataStatus;

  // trang thai cham cong hom nay
  List<ExplanationEntity>? listAttendanceToday;

  List<TaskEntity>? listNewTasks;

  HomeState({
    this.listAttendanceToday,
    this.loadDataStatus = LoadStatus.INITIAL,
    this.listNewTasks
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday,
    LoadStatus? loadDataStatus,
    List<TaskEntity>? listNewTasks
  }) {
    return HomeState(
        listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday,
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      listNewTasks: listNewTasks ?? this.listNewTasks
    );
  }

  @override
  List<Object?> get props => [
    listAttendanceToday,
    loadDataStatus,
    listNewTasks
  ];
}