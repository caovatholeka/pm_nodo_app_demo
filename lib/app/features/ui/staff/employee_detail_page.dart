import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'employee_detail_cubit.dart';

class EmployeeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late final EmployeeDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    final apiClient = GetIt.I.get<ApiClient>();
    _cubit = EmployeeDetailCubit(apiClient: apiClient);
    _cubit.getDetailEmployee(widget.employeeId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  ImageProvider _buildAvatarImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return AssetImage(AppAssets.img_df_avatar);
    }
    try {
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      final bytes = base64Decode(cleaned);
      return MemoryImage(bytes);
    } catch (e) {
      return AssetImage(AppAssets.img_df_avatar);
    }
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.themeBlackDefault,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      bloc: _cubit,
      builder: (context, state) {
        final employee = state.employee;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              "Chi tiết nhân viên",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.imgBg2),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                  ),
                  child: Builder(
                    builder: (_) {
                      if (state.loadStatus == LoadStatus.LOADING) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.loadStatus == LoadStatus.FAILURE) {
                        return const Center(
                          child: Text(
                            "Không thể tải thông tin nhân viên",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      if (employee == null) {
                        return const Center(child: Text("Không có dữ liệu nhân viên"));
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage: _buildAvatarImage(employee.avatarUrl),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    employee.name ?? "Chưa có tên",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    employee.jobTitle ?? "Không có chức vụ",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _TagItem(
                                        label: 'NV${employee.code ?? "--"}',
                                        backgroundColor: const Color(0xFFEAF1FF),
                                        textColor: const Color(0xFF004C9C),
                                      ),
                                      const SizedBox(width: 8),
                                      _TagItem(
                                        label: employee.xlocationType ?? "Văn phòng công ty",
                                        backgroundColor: const Color(0xFFDDF7E3),
                                        textColor: const Color(0xFF2E7D32),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _sectionTitle("Thông tin công việc"),
                            _InfoItem(title: "Chức vụ", value: employee.jobTitle ?? "Chưa có"),
                            _InfoItem(title: "Phòng ban", value: employee.department ?? "Chưa có"),
                            _InfoItem(title: "Quản lý", value: employee.managerby ?? "-"),
                            _InfoItem(title: "Trạng thái", value: "-"),
                            _InfoItem(title: "Ngày gia nhập", value: "-"),
                            _InfoItem(title: "Trạng thái hợp đồng", value: employee.contractStatus ?? "Chưa ký"),
                            const SizedBox(height: 16),
                            _sectionTitle("Thông tin cá nhân"),
                            _InfoRow(icon: Icons.male, label: "Giới tính", value: employee.gender ?? "-"),
                            _InfoRow(icon: Icons.calendar_today, label: "Ngày sinh", value: employee.birthday ?? "-"),
                            _InfoRow(icon: Icons.email_outlined, label: "Email", value: employee.workEmail ?? "Không có"),
                            _InfoRow(icon: Icons.phone, label: "Số điện thoại", value: employee.phone ?? "-"),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: "Địa chỉ",
                              value: "-",
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagItem extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TagItem({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0062FF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
