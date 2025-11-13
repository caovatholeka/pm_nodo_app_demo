part of 'employee_filter_cubit.dart';

class EmployeeFilterState extends Equatable {
  final LoadStatus loadStatus;
  final String? employName;
  final String? employId;
  final String? email;

  // phòng ban
  final List<DepartmentEntity>? listDepartments;
  final String? department;
  final DepartmentEntity? currentDepartment;

  // vị trí công việc
  final List<JobTitleEntity>? listJobTitles;
  final String? jobTitle;
  final JobTitleEntity? currentJobTitle;

  // trạng thái công việc
  final List<MasterDataItem>? listJobStatus;
  final String? jobStatus;
  final MasterDataItem? currentJobStatus;

  const EmployeeFilterState({
    this.loadStatus = LoadStatus.INITIAL,
    this.employName,
    this.employId,
    this.email,
    this.listDepartments,
    this.department,
    this.currentDepartment,
    this.listJobTitles,
    this.jobTitle,
    this.currentJobTitle,
    this.listJobStatus,
    this.jobStatus,
    this.currentJobStatus,
  });

  EmployeeFilterState copyWith({
    LoadStatus? loadStatus,
    String? employName,
    String? employId,
    String? email,
    List<DepartmentEntity>? listDepartments,
    String? department,
    DepartmentEntity? currentDepartment,
    List<JobTitleEntity>? listJobTitles,
    String? jobTitle,
    JobTitleEntity? currentJobTitle,
    List<MasterDataItem>? listJobStatus,
    String? jobStatus,
    MasterDataItem? currentJobStatus
  }){
    return EmployeeFilterState(
        loadStatus: loadStatus ?? this.loadStatus,
       employName: employName ?? this.employName,
      employId: employId ?? this.employId,
      email: email ?? this.email,
      listDepartments: listDepartments ?? this.listDepartments,
      department: department ?? this.department,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      listJobTitles: listJobTitles ?? this.listJobTitles,
      jobTitle: jobTitle ?? this.jobTitle,
      currentJobTitle: currentJobTitle ?? this.currentJobTitle,
      listJobStatus: listJobStatus ?? this.listJobStatus,
      jobStatus: jobStatus ?? this.jobStatus,
      currentJobStatus: currentJobStatus ?? this.currentJobStatus
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    employName,
    employId,
    email,
    listDepartments,
    department,
    currentDepartment,
    listJobTitles,
    jobTitle,
    currentJobTitle,
    listJobStatus,
    currentJobStatus,
    jobStatus
  ];
}