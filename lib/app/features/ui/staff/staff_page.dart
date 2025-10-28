import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final List<Map<String, String>> employees = [
    {
      "name": "Nguyễn Minh Dũng",
      "dept": "Phòng ban: UI/UX",
      "code": "NV03102",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Tạ Quang Mạnh",
      "dept": "Phòng ban: BA",
      "code": "NV01231",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Nguyễn Văn An",
      "dept": "Phòng ban: Developer",
      "code": "NV01232",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Lê Thị Thùy",
      "dept": "Phòng ban: Tester",
      "code": "NV01231",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Trần Minh Tuấn",
      "dept": "Phòng ban: Marketing",
      "code": "NV01233",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Phạm Thị Hằng",
      "dept": "Phòng ban: HR",
      "code": "NV01234",
      "image": AppAssets.img_df_avatar,
    },
    {
      "name": "Ngô Văn Khải",
      "dept": "Phòng ban: Sales",
      "code": "NV01235",
      "image": AppAssets.img_df_avatar,
    },
  ];

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Ô tìm kiếm + filter + nút thêm
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.grey, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.colorPrimary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách nhân viên
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(emp["image"]!),
                      ),
                      title: Text(
                        emp["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        emp["dept"]!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Text(
                        emp["code"]!,
                        style: const TextStyle(
                          color: Color(0xFF3C8DF4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
