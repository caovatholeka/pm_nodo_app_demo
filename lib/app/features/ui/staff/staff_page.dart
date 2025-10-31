import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/data/local/master_data.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/employee_detail_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import '../../widgets/input_text_field.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _cubit = GetIt.I.get<StaffCubit>();
  final _searchController = TextEditingController();

  List<MasterDataItem> listDateTypeLeaves = [
    MasterDataItem(text: "Nghỉ phép")
  ];

  @override
  void initState() {
    super.initState();
    _cubit.getListEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final employees = _cubit.state.listEmployees ?? [];
    final departments = MasterData.getDepartmentsFromEmployees(employees);
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

                    _buildDropdownInput(
                      "Phòng ban",
                      "Chọn phòng ban",
                      departments,
                      selectedDept,
                      (val) => setState(() => selectedDept = val),
                    ),
                    const SizedBox(height: 10),

                    _buildDropdownInput(
                      "Vị trí công việc",
                      "Chọn vị trí công việc",
                      jobTitles,
                      selectedJob,
                      (val) => setState(() => selectedJob = val),
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

                    _buildDropdownInput(
                      "Trạng thái",
                      "Chọn trạng thái",
                      statuses,
                      selectedStatus,
                      (val) => setState(() => selectedStatus = val),
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
                          backgroundColor:
                              const Color.fromARGB(255, 0, 98, 255),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Danh sách nhân viên",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: Colors.black54),
          ),
        ],
      ),
      body: Stack(
        children: [
          /// Ảnh nền
          Positioned.fill(
            child: Image.asset(
              AppAssets.imgBg2,
              fit: BoxFit.cover,
            ),
          ),

          /// Nội dung
          BlocBuilder<StaffCubit, StaffState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.loadStatus == LoadStatus.LOADING) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.loadStatus == LoadStatus.FAILURE) {
                return const Center(
                    child: Text("Không thể tải danh sách nhân viên"));
              }

              final employees = state.listEmployees ?? [];

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white.withOpacity(0.85),
                      child: Column(
                        children: [
                          // 🔹 Search bar nằm ngay trên danh sách
                          Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
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
                                      hintText:
                                          "Mã nhân viên, Tên nhân viên",
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.tune_rounded,
                                      color: Colors.grey, size: 22),
                                  onPressed: _openFilterSheet,
                                ),
                              ],
                            ),
                          ),

                          // 🔹 Danh sách nhân viên
                          Expanded(
                            child: employees.isEmpty
                                ? const Center(
                                    child: Text("Không có nhân viên nào"))
                                : ListView.builder(
                                    itemCount: employees.length,
                                    itemBuilder: (context, index) {
                                      final emp = employees[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              (emp.avatarUrl != null &&
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
                                              height: 1.3),
                                        ),
                                        trailing: Text(
                                          emp.code != null ? "NV${emp.code}" : "",
                                          style: const TextStyle(
                                            color: Color(0xFF3C8DF4),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EmployeeDetailPage(employee: emp),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownInput(
    String title,
    String hint,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    final controller = TextEditingController(text: selectedValue ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = item == selectedValue;

                          return ListTile(
                            title: Text(
                              item,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.grey
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onChanged(item);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
        child: AbsorbPointer(
          child: InputTextField(
            title: title,
            hintText: hint,
            isRequiredField: false,
            enable: true,
            readOnly: true,
            controller: controller,
            suffixIcon: AppAssets.icArrowDown,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
            bgrColor: true,
          ),
        ),
      ),
    );
  }
}
