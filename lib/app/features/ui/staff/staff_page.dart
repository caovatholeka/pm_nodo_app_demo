import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/data/local/master_data.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/employee_detail_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart' as widgets;

import '../../widgets/loading_more_row_widget.dart';

class StaffPage extends StatefulWidget {
  bool? isFromHome;
  StaffPage({super.key,this.isFromHome});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _cubit = GetIt.I.get<StaffCubit>();
  final _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _cubit.getListEmployees();
    _scrollController.addListener(_onMaxScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onMaxScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMaxScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      final state = _cubit.state;
      if (state.loadEventStatus != LoadStatus.LOADING_MORE) {
        _cubit.onLoadMore();
      }
    }
  }

  Future<void> _openFilterSheet() async {
    final employees = _cubit.state.listEmployees ?? [];
    final departments = await MasterData.getDepartmentsFromApi();
    final jobTitles = MasterData.getJobTitlesFromEmployees(employees);
    final statuses = MasterData.employeeStatuses;
    final currentFilter = _cubit.state.filter;
    final nameController =
        TextEditingController(text: currentFilter?.name ?? "");
    final codeController =
        TextEditingController(text: currentFilter?.code ?? "");
    final emailController =
        TextEditingController(text: currentFilter?.email ?? "");

    String? selectedDept = currentFilter?.department;
    String? selectedJob = currentFilter?.jobTitle;
    String? selectedStatus;

    if (currentFilter?.active == true) {
      selectedStatus = "Đang làm việc";
    } else if (currentFilter?.active == false) {
      selectedStatus = "Đã nghỉ việc";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            nameController.clear();
                            codeController.clear();
                            emailController.clear();
                            selectedDept = null;
                            selectedJob = null;
                            selectedStatus = null;
                            _cubit.clearFilter();
                            setState(() {});
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
                    const SizedBox(height: 30),
                    InputTextField(
                      title: "Tên nhân viên",
                      hintText: "Nhập tên nhân viên",
                      isRequiredField: false,
                      controller: nameController,
                      enable: true,
                    ),
                    const SizedBox(height: 10),
                    InputTextField(
                      title: "Mã nhân viên",
                      hintText: "Nhập mã nhân viên",
                      isRequiredField: false,
                      controller: codeController,
                      enable: true,
                    ),
                    const SizedBox(height: 10),
                    widgets.DropdownInputField(
                      title: "Phòng ban",
                      hint: "Chọn phòng ban",
                      items: departments,
                      selectedValue: selectedDept,
                      onChanged: (val) => setState(() => selectedDept = val),
                    ),
                    const SizedBox(height: 10),
                    widgets.DropdownInputField(
                      title: "Chức vụ",
                      hint: "Chọn chức vụ",
                      items: jobTitles,
                      selectedValue: selectedJob,
                      onChanged: (val) => setState(() => selectedJob = val),
                    ),
                    const SizedBox(height: 10),
                    InputTextField(
                      title: "Email",
                      hintText: "Nhập Email",
                      isRequiredField: false,
                      controller: emailController,
                      enable: true,
                    ),
                    const SizedBox(height: 10),
                    widgets.DropdownInputField(
                      title: "Trạng thái",
                      hint: "Chọn trạng thái",
                      items: statuses,
                      selectedValue: selectedStatus,
                      onChanged: (val) => setState(() => selectedStatus = val),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final activeValue = selectedStatus == "Đang làm việc"
                              ? true
                              : selectedStatus == "Đã nghỉ việc"
                                  ? false
                                  : null;

                          final filter = EmployeeFilterParam(
                            name: nameController.text,
                            code: codeController.text,
                            email: emailController.text,
                            department: selectedDept,
                            jobTitle: selectedJob,
                            active: activeValue,
                          );

                          _cubit.filterEmployees(filter);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0062FF),
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
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Danh sách nhân viên",
        haveBackButton: (widget.isFromHome ?? false) ? true : false,
        haveActionButton: true,
        iconPathAsset: AppAssets.ic_bell,
        actionCallBack: () {},
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.imgBg2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: BlocBuilder<StaffCubit, StaffState>(
              bloc: _cubit,
              buildWhen: (prev,cur) =>  prev.loadStatus != cur.loadStatus
                || prev.listEmployees != cur.listEmployees
                || prev.loadEventStatus != cur.loadEventStatus,
              builder: (context, state) {
                if (state.loadStatus == LoadStatus.LOADING) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.loadStatus == LoadStatus.FAILURE) {
                  return const Center(
                      child: Text("Không thể tải danh sách nhân viên"));
                }
                final isShowLoadMore = state.loadEventStatus == LoadStatus.LOADING_MORE ? true : false;
                final employees = state.listEmployees ?? [];

                return Padding(
                  padding: const EdgeInsets.all(5), 
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Colors.grey, size: 22),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _cubit.searchEmployees,
                                  decoration: const InputDecoration(
                                    hintText: "Mã nhân viên, Tên nhân viên",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _openFilterSheet(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0062FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: employees.isEmpty
                              ? const Center(
                                  child: Text("Không có nhân viên nào"),
                                )
                              : Stack(
                            children: [
                              RefreshIndicator(
                                  onRefresh: () async => _cubit.getListEmployees(),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: employees.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    itemBuilder: (context, index) {
                                      final emp = employees[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: ListTile(
                                          leading: AppCircleAvatar(
                                              url: emp.avatarUrl ?? "",
                                              size: 58,
                                          ),
                                          // leading: CircleAvatar(
                                          //   radius: 24,
                                          //   backgroundImage: (emp.avatarUrl !=
                                          //       null &&
                                          //       emp.avatarUrl!.isNotEmpty)
                                          //       ? NetworkImage(emp.avatarUrl!)
                                          //       : AssetImage(
                                          //       AppAssets.img_df_avatar)
                                          //   as ImageProvider,
                                          // ),
                                          title: Text(
                                            emp.name ?? "Không có tên",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              fontSize: 15,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Phòng ban: ${emp.department ?? 'Chưa có'}\n${emp.jobTitle ?? ''}",
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                              height: 1.3,
                                            ),
                                          ),
                                          trailing: Text(
                                            emp.code != null
                                                ? "NV${emp.code}"
                                                : "",
                                            style: const TextStyle(
                                              color:
                                              Color.fromARGB(255, 0, 98, 255),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                 builder: (_) => EmployeeDetailPage(employeeId: emp.id ?? 0),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ), ),
                              Positioned.fill(
                                bottom: 3,
                                child: Visibility(
                                  visible: isShowLoadMore,
                                  child: const Align(
                                    alignment: Alignment.bottomCenter,
                                    child: LoadingMoreRowWidget(),
                                  ),
                                ),
                              ),
                            ],
                          )
                          /*ListView.builder(
                                  itemCount: employees.length,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  itemBuilder: (context, index) {
                                    final emp = employees[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundImage: (emp.avatarUrl !=
                                                      null &&
                                                  emp.avatarUrl!.isNotEmpty)
                                              ? NetworkImage(emp.avatarUrl!)
                                              : AssetImage(
                                                      AppAssets.img_df_avatar)
                                                  as ImageProvider,
                                        ),
                                        title: Text(
                                          emp.name ?? "Không có tên",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Phòng ban: ${emp.department ?? 'Chưa có'}\n${emp.jobTitle ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                        trailing: Text(
                                          emp.code != null
                                              ? "NV${emp.code}"
                                              : "",
                                          style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 98, 255),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EmployeeDetailPage(
                                                      employee: emp),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                          */
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
