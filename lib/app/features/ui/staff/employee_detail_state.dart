part of 'employee_detail_cubit.dart';

class EmployeeDetailState extends Equatable {
  final LoadStatus loadStatus;
  final EmployeeEntity? employee;

  const EmployeeDetailState({
    required this.loadStatus,
    this.employee,
  });

  factory EmployeeDetailState.initial() =>
      const EmployeeDetailState(loadStatus: LoadStatus.SUCCESS);

  EmployeeDetailState copyWith({
    LoadStatus? loadStatus,
    EmployeeEntity? employee,
  }) {
    return EmployeeDetailState(
      loadStatus: loadStatus ?? this.loadStatus,
      employee: employee ?? this.employee,
    );
  }

  @override
  List<Object?> get props => [loadStatus, employee];
}
