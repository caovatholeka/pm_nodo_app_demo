import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/commons/app_colors.dart';
import '../../../core/commons/app_assets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
          'Xin chào',
          style: TextStyle(
          fontSize: 20,
          color: AppColors.themeBlackDefault,
          ),
        ),
          const SizedBox(height: 4),
          const Text(
          'Nguyễn Đăng Huy',
          style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.themeBlackDefault,
        ),
      ),
   ],
 ),
),
    GestureDetector(
      onTap: () {
        print("No event yet");         
      },
      child: Container(
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
      )
    ],
  ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(AppAssets.ic_new_noti),
      ),
    )
  ],
    ),
      const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Mã nhân viên, Tên nhân viên',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(AppAssets.ic_search, width: 20, height: 20),
                  ),
                  filled: true,
                  fillColor:AppColors.colorPrimary50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Tiện ích',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.menuText
                    ),
                  ),
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: AppColors.menuText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 12,
                children: [
                  _buildMenuItemWithAsset(AppAssets.ic_employee, 'Nhân viên'),
                  _buildMenuItemWithAsset(AppAssets.ic_paper, 'Dữ liệu công'),
                  _buildMenuItemWithAsset(AppAssets.ic_paper2, 'Nghỉ phép'),
                  _buildMenuItemWithAsset(AppAssets.ic_timekeeping, 'Chấm công'),
                  _buildMenuItemWithAsset(AppAssets.ic_employee, 'Nhân viên'),
                  _buildMenuItemWithAsset(AppAssets.ic_paper, 'Dữ liệu công'),
                  _buildMenuItemWithAsset(AppAssets.ic_paper2, 'Nghỉ phép'),
                  _buildMenuItemWithAsset(AppAssets.ic_timekeeping, 'Chấm công'),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppAssets.ic_roundG),
                        const SizedBox(width: 6),
                        const Text(
                          'Thứ 5, 25/08/2025',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Đúng giờ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chấm công vào/ra: 08:50 - 18:00',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithAsset(String assetPath, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.colorPrimary50
          ),
          child: Image.asset(assetPath, width: 28, height: 28),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
