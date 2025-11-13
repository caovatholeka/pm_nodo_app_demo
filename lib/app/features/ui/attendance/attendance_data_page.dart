import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_tab.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/development_alert_dialog.dart';


class AttendanceDataPage extends StatefulWidget {
  const AttendanceDataPage({super.key});

  @override
  State<AttendanceDataPage> createState() => _AttendanceDataPageState();
}

class _AttendanceDataPageState extends State<AttendanceDataPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Dữ liệu chấm công",
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.ic_bell,
        actionCallBack: () => DevelopmentAlertDialog.show(context),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: Colors.white),
                      insets: EdgeInsets.symmetric(horizontal: 32.0),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: "Dữ liệu chấm công"),
                      Tab(text: "Giải trình công"),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: AppShadow.pageBoxShadow,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        AttendanceTab(),
                        ExplanationTab(),
                      ],
                    ),
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
