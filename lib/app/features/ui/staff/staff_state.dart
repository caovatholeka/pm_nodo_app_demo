part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  final List<EmployeeEntity>? listEmployees;
  final EmployeeFilterParam? filter;

  const StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.listEmployees,
    this.filter,
  });

  StaffState copyWith({
    LoadStatus? loadStatus,
    List<EmployeeEntity>? listEmployees,
    EmployeeFilterParam? filter,
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      listEmployees: listEmployees ?? this.listEmployees,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [loadStatus, listEmployees, filter];
}
