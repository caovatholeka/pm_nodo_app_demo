import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/param/employee_filter_param.dart';

import '../../../../data/models/entities/department_entity.dart';
import '../../../../data/models/entities/job_title_entity.dart';
import '../../../../data/models/entities/master_data_item.dart';
import '../../../../data/models/enums/load_status.dart';

part 'employee_filter_state.dart';

class EmployeeFilterCubit extends Cubit<EmployeeFilterState> {
  EmployeeFilterCubit() : super(EmployeeFilterState());


  // mock data
  initData() async{
    emit(state.copyWith(loadStatus: LoadStatus.LOADING));
    try{
      // lay danh sach phong
      final departments = [
        DepartmentEntity(name: "Phòng sản xuất",code: "SX"),
        DepartmentEntity(name: "Phòng nhân sự",code: "NS"),
        DepartmentEntity(name: "Phòng kế toán",code: "KT"),
        DepartmentEntity(name: "Phòng kinh doanh",code: "KD")
      ];
      // lay danh sach job title
      final jobTitles = [
        JobTitleEntity(name: "UI/UX Designer",code: "UI/UX"),
        JobTitleEntity(name: "Developer",code: "Dev"),
        JobTitleEntity(name: "Tester",code: "Test"),
        JobTitleEntity(name: "Manager",code: "Manager")
      ];

      // lay danh sach trang thai cong viec
      final jobStatus = [
        MasterDataItem(text: "Tất cả",code: "all"),
        MasterDataItem(text: "Đang làm việc",code: "Working"),
        MasterDataItem(text: "Đã nghỉ",code: "Leave"),
      ];

      emit(state.copyWith(listDepartments: departments,
          listJobTitles: jobTitles,listJobStatus: jobStatus,
          loadStatus: LoadStatus.SUCCESS));
    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadStatus: LoadStatus.FAILURE));
    }


  }

  onChangeEmployeeName(String name){
    emit(state.copyWith(employName: name));
  }

  onChangeEmployId(String id){
    emit(state.copyWith(employId: id));
  }

  onChangeCurrentDepartment(DepartmentEntity department){
    emit(state.copyWith(currentDepartment: department, department: department.name));
  }

  onChangeCurrentJobTitle(JobTitleEntity job){
    emit(state.copyWith(currentJobTitle: job, jobTitle: job.name));
  }

  onChangeEmail(String email){
    emit(state.copyWith(email: email));
  }

  onChangeJobStatus(MasterDataItem status){
    emit(state.copyWith(currentJobStatus: status,jobStatus: status.text));
  }

  getCurrentFilter(){
    EmployeeFilterParam param = EmployeeFilterParam(
      employeeName: state.employName,
      employeeId: state.employId,
      departmentName: state.department ?? ""
    );

    return param;
  }
}