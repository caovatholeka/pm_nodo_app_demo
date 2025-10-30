import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';

class EmployeeDetailPage extends StatelessWidget {
  final EmployeeEntity employee;

  const EmployeeDetailPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
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
            decoration:BoxDecoration(
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
              child: SingleChildScrollView(
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
                            backgroundImage: (employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty)
                                ? NetworkImage(employee.avatarUrl!)
                                :AssetImage(AppAssets.img_df_avatar) as ImageProvider,
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
                                label: 'NV'+ (employee.code ?? "Chưa có mã"),
                                backgroundColor: const Color(0xFFEAF1FF),
                                textColor: const Color(0xFF004C9C),
                              ),
                              const SizedBox(width: 8),
                              const _TagItem(
                                label: "Văn phòng công ty",
                                backgroundColor: Color(0xFFDDF7E3),
                                textColor: Color(0xFF2E7D32),
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
                    _InfoItem(title: "Quản lý", value: "Trần Xuân Trường"),
                    _InfoItem(title: "Trạng thái", value: "Đang làm việc"),
                    _InfoItem(title: "Ngày gia nhập", value: "02/10/2025"),
                    _InfoItem(title: "Trạng thái hợp đồng", value: "Chưa ký"),
                    const SizedBox(height: 16),

                    _sectionTitle("Thông tin cá nhân"),
                    _InfoRow(icon: Icons.male, label: "Giới tính", value: "Nam"),
                    _InfoRow(icon: Icons.calendar_today, label: "Ngày sinh", value: "03/01/2002"),
                    _InfoRow(icon: Icons.email_outlined, label: "Email", value: employee.workEmail ?? "Không có"),
                    _InfoRow(icon: Icons.phone, label: "Số điện thoại", value: "0845733708"),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: "Địa chỉ",
                      value: "24 Nguyễn Cơ Thạch, Mỹ Đình 1, Nam Từ Liêm, Hà Nội",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}

// Thẻ trạng thái
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
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
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
          Icon(icon, color: const Color.fromARGB(255, 0, 98, 255), size: 22),
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
