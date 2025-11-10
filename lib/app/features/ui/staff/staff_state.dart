part of 'staff_cubit.dart';

class StaffState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus loadEventStatus;
  final List<EmployeeEntity>? listEmployees;
  final int page;
  final int totalPages;
  final EmployeeFilterParam? filterParam;

  const StaffState({
    this.loadStatus = LoadStatus.INITIAL,
    this.loadEventStatus = LoadStatus.INITIAL,
    this.listEmployees,
    this.page = 0,
    this.totalPages = 0,
    this.filterParam, 
  });

  StaffState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadEventStatus,
    List<EmployeeEntity>? listEmployees,
    int? page,
    int? totalPages,
    EmployeeFilterParam? filterParam,
  }) {
    return StaffState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadEventStatus: loadEventStatus ?? this.loadEventStatus,
      listEmployees: listEmployees ?? this.listEmployees,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      filterParam: filterParam ?? this.filterParam,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        loadEventStatus,
        listEmployees,
        page,
        totalPages,
        filterParam,
      ];
}
