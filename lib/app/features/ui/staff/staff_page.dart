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
      body: Container(
        width: double.infinity,
        child: Column(
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
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.grey, size: 20),
                  ),
                  const SizedBox(width: 8),
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

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final EmployeeEntity emp = employees[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: (emp.avatarUrl != null && emp.avatarUrl!.isNotEmpty)
                                ? NetworkImage(emp.avatarUrl!)
                                : AssetImage(AppAssets.img_df_avatar),
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
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Text(
                            'NV: ${emp.code ?? "Làm gì có mã :v"}',
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
