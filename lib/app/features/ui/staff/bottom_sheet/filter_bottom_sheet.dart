import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/department_entity.dart';
import 'package:pm_app/app/data/models/entities/job_title_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/features/ui/staff/bottom_sheet/employee_filter_cubit.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../../data/models/param/employee_filter_param.dart';
import '../../../widgets/common_bottom_sheet.dart';

class FilterBottomSheet extends StatefulWidget {
  EmployeeFilterParam? filterParam;

  FilterBottomSheet({
    Key? key,
    this.filterParam,
  }): super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  final _filterCubit = GetIt.I.get<EmployeeFilterCubit>();

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final jobTitleController = TextEditingController();
  final jobStatusController = TextEditingController();

  String? selectedDept;
  String? selectedJob;
  String? selectedStatus;

  @override
  void initState() {
    _filterCubit.initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  // _openDepartmentBottomSheet(List<DepartmentEntity> list,DepartmentEntity current ) async{
  //   final item = await showModalBottomSheet(
  //       context: context,
  //       backgroundColor: Colors.transparent,
  //       useRootNavigator: true,
  //       isScrollControlled: true,
  //       builder: (BuildContext context) =>
  //           CommonBottomSheet(
  //             listValues: list,
  //             currentValue: _createCubit.state.currentDateLeaveType ,
  //             title: "Phòng ban",
  //           )
  //   );
  //
  //   if(item != null ){
  //     _createCubit.onChangeDateTypeLeaves(item);
  //   }
  // }

  _openJobStatusBottomSheet(List<MasterDataItem> list,MasterDataItem current ) async{
    final item = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            CommonBottomSheet(
              listValues: list,
              currentValue: current ,
              title: "Trạng thái",
            )
    );

    if(item != null ){
      _filterCubit.onChangeJobStatus(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bộ lọc nâng cao",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Xóa lọc",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                    bloc: _filterCubit,
                    buildWhen: (prev,cur) => prev.employName != cur.employName,
                    builder: (context,state){
                      return  InputTextField(
                        title: "Tên nhân viên",
                        hintText: "Nhập tên nhân viên",
                        isRequiredField: false,
                        controller: nameController..text = state.employName ?? "",
                        enable: true,
                        onChange: (value){
                          _filterCubit.onChangeEmployeeName(value);
                        },
                      ).paddingOnly(bottom: 16);
                    }),

                BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                    bloc: _filterCubit,
                    buildWhen: (prev,cur) => prev.employId != cur.employId,
                    builder: (context,state){
                      return InputTextField(
                        title: "Mã nhân viên",
                        hintText: "Nhập mã nhân viên",
                        isRequiredField: false,
                        controller: codeController..text = state.employId ?? "",
                        enable: true,
                        onChange: (value){
                          _filterCubit.onChangeEmployId(value);
                        },
                      ).paddingOnly(bottom: 16);
                    }),

              BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                  buildWhen: (prev,cur) => prev.listDepartments != cur.listDepartments ||
                    prev.currentDepartment != cur.currentDepartment ||
                    prev.department != cur.department,
                  builder: (context,state){
                    return InputTextField(
                      title: "Phòng ban",
                      hintText: "Chọn phòng ban",
                      isRequiredField: false,
                      controller: departmentController,
                      enable: true,
                      readOnly: true,
                      suffixIcon: AppAssets.icArrowDown,
                      callback: (){
                        // open bottom sheet phong ban
                      },
                    ).paddingOnly(bottom: 20);
                  }),

              BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                  bloc: _filterCubit,
                  buildWhen: (prev,cur) => prev.listJobTitles != cur.listJobTitles ||
                    prev.jobTitle != cur.jobTitle ||
                    prev.currentJobTitle != cur.currentJobTitle,
                  builder: (context,state){
                    return InputTextField(
                      title: "Vị trí công việc",
                      hintText: "Chọn vị trí công việc",
                      isRequiredField: false,
                      controller: jobTitleController,
                      enable: true,
                      readOnly: true,
                      suffixIcon: AppAssets.icArrowDown,
                      callback: (){
                        // open bottom sheet Vị trí công việc
                      },
                    ).paddingOnly(bottom: 20);
                  }),

                BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                    bloc: _filterCubit,
                    buildWhen: (prev,cur) => prev.email != cur.email,
                    builder: (context,state){
                      return InputTextField(
                        title: "Email",
                        hintText: "email",
                        isRequiredField: false,
                        controller: emailController,
                        enable: true,
                        onChange: (value){

                        },
                      ).paddingOnly(bottom: 20);
                    }),

                BlocBuilder<EmployeeFilterCubit,EmployeeFilterState>(
                    bloc: _filterCubit,
                    buildWhen: (prev,cur)=> prev.listJobStatus != cur.listJobStatus ||
                      prev.jobStatus != cur.jobStatus || prev.currentJobStatus != cur.currentJobStatus,
                    builder: (context,state){
                      return InputTextField(
                        title: "Trạng thái",
                        hintText: "Chọn trạng thái",
                        isRequiredField: false,
                        controller: departmentController,
                        enable: true,
                        readOnly: true,
                        suffixIcon: AppAssets.icArrowDown,
                        callback: (){
                          // open bottom sheet trang thai
                          _openJobStatusBottomSheet(state.listJobStatus ?? [],state.currentJobStatus ?? MasterDataItem());
                        },
                      ).paddingOnly(bottom: 20);
                    }),


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      EmployeeFilterParam filter = _filterCubit.getCurrentFilter();
                      Navigator.pop(context, filter);
                      // _cubit.filterEmployees(
                      //   name: nameController.text,
                      //   code: codeController.text,
                      //   email: emailController.text,
                      //   department: selectedDept,
                      //   jobTitle: selectedJob,
                      //   status: selectedStatus,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Áp dụng",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
