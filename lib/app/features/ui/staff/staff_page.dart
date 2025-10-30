import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui/staff/employee_detail_page.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _cubit = GetIt.I.get<StaffCubit>();
  final _searchController = TextEditingController();

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final nameController = TextEditingController();
        final codeController = TextEditingController();
        final emailController = TextEditingController();
        String? selectedDept;
        String? selectedJob;
        String? selectedStatus;

        final departments = ['Phòng sản xuất', 'Phòng nhân sự', 'Phòng kế toán'];
        final jobTitles = ['UI/UX Designer', 'Developer', 'Tester', 'Manager'];
        final statuses = ['Đang làm việc', 'Nghỉ phép', 'Đã nghỉ'];

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
                            nameController.clear();
                            codeController.clear();
                            emailController.clear();
                            selectedDept = null;
                            selectedJob = null;
                            selectedStatus = null;
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
                    const SizedBox(height: 16),

                    _buildInputField("Tên nhân viên", "Nhập tên nhân viên", nameController),
                    const SizedBox(height: 10),

                    _buildInputField("Mã nhân viên", "Nhập mã nhân viên", codeController),
                    const SizedBox(height: 10),

                    _buildDropdown(
                      "Phòng ban",
                      "Chọn phòng ban",
                      departments,
                      selectedDept,
                      (val) => setState(() => selectedDept = val),
                    ),
                    const SizedBox(height: 10),

                    _buildDropdown(
                      "Vị trí công việc",
                      "Chọn vị trí công việc",
                      jobTitles,
                      selectedJob,
                      (val) => setState(() => selectedJob = val),
                    ),
                    const SizedBox(height: 10),

                    _buildInputField("Email", "Nhập Email", emailController),
                    const SizedBox(height: 10),

                    _buildDropdown(
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
                          _cubit.filterEmployees(
                            name: nameController.text,
                            code: codeController.text,
                            email: emailController.text,
                            department: selectedDept,
                            jobTitle: selectedJob,
                            status: selectedStatus,
                          );
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
      backgroundColor: const Color(0xFFE9F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
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
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black54),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _cubit.searchEmployees,
                    decoration: const InputDecoration(
                      hintText: "Mã nhân viên, Tên nhân viên",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.grey, size: 22),
                  onPressed: _openFilterSheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Expanded(
            child: BlocBuilder<StaffCubit, StaffState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state.loadStatus == LoadStatus.LOADING) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.loadStatus == LoadStatus.FAILURE) {
                  return const Center(child: Text("Không thể tải danh sách nhân viên"));
                }

                final employees = state.listEmployees ?? [];

                if (employees.isEmpty) {
                  return const Center(child: Text("Không có nhân viên nào"));
                }

                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final EmployeeEntity emp = employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: (emp.avatarUrl != null && emp.avatarUrl!.isNotEmpty)
                            ? NetworkImage(emp.avatarUrl!)
                            : AssetImage(AppAssets.img_df_avatar) as ImageProvider,
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
                        "Phòng ban: ${emp.department ?? 'Chưa có'}",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      trailing: Text(
                        'NV: ${emp.code ?? "Không có mã"}',
                        style: const TextStyle(
                          color: Color(0xFF3C8DF4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeDetailPage(employee: emp),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String hint,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
