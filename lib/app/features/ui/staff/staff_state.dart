part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus loadEventStatus;
  final List<EmployeeEntity>? listEmployees;
  final EmployeeFilterParam? filter;

  final int page;
  final int totalPages;

  const StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.listEmployees,
    this.filter,
    this.loadEventStatus= LoadStatus.INITIAL,
    this.page = 0,
    this.totalPages = 0
  });

  StaffState copyWith({
    LoadStatus? loadStatus,
    List<EmployeeEntity>? listEmployees,
    EmployeeFilterParam? filter,
    LoadStatus? loadEventStatus,
    int? page,
    int? totalPages
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      listEmployees: listEmployees ?? this.listEmployees,
      filter: filter ?? this.filter,
      loadEventStatus: loadEventStatus ?? this.loadEventStatus,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages
    );
  }

  @override
  List<Object?> get props => [loadStatus,
    listEmployees, filter,
    loadEventStatus,
    page,
    totalPages
  ];
}
