part of 'home_cubit.dart';

class HomeState extends Equatable {
  // trang thai cham cong hom nay
  List<ExplanationEntity>? listAttendanceToday;

  HomeState({
    this.listAttendanceToday
  });

  HomeState copyWith({
    List<ExplanationEntity>? listAttendanceToday
  }) {
    return HomeState(
        listAttendanceToday: listAttendanceToday ?? this.listAttendanceToday
    );
  }

  @override
  List<Object?> get props => [
    listAttendanceToday
  ];
}