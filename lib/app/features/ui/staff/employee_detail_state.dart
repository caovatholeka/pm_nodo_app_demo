part of 'employee_detail_cubit.dart';

enum LoadStatus { LOADING, SUCCESS, FAILURE }

class EmployeeDetailState extends Equatable {
  final EmployeeEntity? employee;
  final LoadStatus loadStatus;
  final String? error;

  const EmployeeDetailState({
    this.employee,
    required this.loadStatus,
    this.error,
  });

  factory EmployeeDetailState.initial() => const EmployeeDetailState(loadStatus: LoadStatus.SUCCESS);

  EmployeeDetailState copyWith({
    EmployeeEntity? employee,
    LoadStatus? loadStatus,
    String? error,
  }) {
    return EmployeeDetailState(
      employee: employee ?? this.employee,
      loadStatus: loadStatus ?? this.loadStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [employee, loadStatus, error];
}
