import 'package:flutter/material.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/features/widgets/attendance_card.dart' as widgets;

import 'package:pm_app/app/features/widgets/input_text_field.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/commons/app_assets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _appCubit = GetIt.I<AppCubit>();

  final _searchController = TextEditingController();

  @override
  void initState() {
    _appCubit.getProfile(); 
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _goNotifi() {
  Navigator.push(context,
         MaterialPageRoute(
        builder:(context) => NotificationPage()
        ));
}

void _goAttendanceData() {
  Navigator.push(context,
         MaterialPageRoute(
        builder:(context) => AttendanceDataPage()
        ));
}

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      child : SingleChildScrollView(
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
          'Xin chào,',
          style: TextStyle(
          fontSize: 20,
          color: AppColors.themeBlackDefault,
          ),
        ),
        const SizedBox(height: 4),
        BlocBuilder<AppCubit,AppState>(
            bloc: _appCubit,
            buildWhen: (prev,cur) => prev.userProfile != cur.userProfile,
            builder: (context,state){
              return Text(
                state.userProfile?.name ?? "",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeBlackDefault,
                ),
              );
            })

   ],
 ),
),
    GestureDetector(
      onTap: () {
         _goNotifi();       
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
       InputTextField(
        title: "", 
        hintText: "Mã nhân viên, Tên nhân viên", 
        isRequiredField: false,
        maxLength: 255,
        controller: _searchController,
        style: TextStyle(color: AppColors.searchText),
        bgrColor: true,
        prefixWidget: Image.asset(
          AppAssets.ic_search,
          width: 20,
          height: 20,
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
                  _buildMenuItemWithAsset(
                    AppAssets.ic_employee, 'Nhân viên', onTap: () => {},),
                  _buildMenuItemWithAsset(AppAssets.ic_paper, 'Dữ liệu công',onTap: () => {
                      _goAttendanceData()
                  }),
                  _buildMenuItemWithAsset(AppAssets.ic_paper2, 'Nghỉ phép',onTap: () => {}),
                  _buildMenuItemWithAsset(AppAssets.ic_timekeeping, 'Chấm công',onTap: () => {}),
                  _buildMenuItemWithAsset(AppAssets.ic_employee, 'Nhân viên',onTap: () => {}),
                  _buildMenuItemWithAsset(AppAssets.ic_paper, 'Dữ liệu công',onTap: () => {}),
                  _buildMenuItemWithAsset(AppAssets.ic_paper2, 'Nghỉ phép',onTap: () => {}),
                  _buildMenuItemWithAsset(AppAssets.ic_timekeeping, 'Chấm công',onTap: () => {}),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widgets.AttendanceCard(
                  date: "Thứ 3, 4/11/2025",
                 status: "Đúng giờ",
                 timerage: "08:00 - 17:00",
                 iconPath: AppAssets.ic_roundG
                 ),
              ),
            ],
          ),
        ),
      ),
      )
    );
  }

}
Widget _buildMenuItemWithAsset(String assetPath, String title, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.colorPrimary50,
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
    ),
  );
}