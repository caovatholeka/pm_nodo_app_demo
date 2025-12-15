part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus loadEventStatus;
  final List<EmployeeEntity>? listEmployees;
  final int page;
  final int totalPages;
  final EmployeeFilterParam? filterParam;

  final EmployeeEntity? employee;
  

  const StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.loadEventStatus = LoadStatus.INITIAL,
    this.listEmployees,
    this.employee,
    this.page = 1,
    this.totalPages = 0,
    this.filterParam, 
  });

  StaffState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadEventStatus,
    List<EmployeeEntity>? listEmployees,
    int? page,
    EmployeeEntity? employee,
    int? totalPages,
    EmployeeFilterParam? filterParam,
    bool clearFilter = false,
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadEventStatus: loadEventStatus ?? this.loadEventStatus,
      listEmployees: listEmployees ?? this.listEmployees,
      employee: employee ?? this.employee,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      filterParam: clearFilter ? null : (filterParam ?? this.filterParam),
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        loadEventStatus,
        listEmployees,
        employee,
        page,
        totalPages,
        filterParam,
      ];
}
