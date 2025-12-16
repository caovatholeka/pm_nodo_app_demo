import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/custom_dash_view.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

import 'bloc/justification_detail_cubit.dart';

class JustificationDetailPage extends StatefulWidget {
  final int? id;
  const JustificationDetailPage({super.key, this.id});

  @override
  State<JustificationDetailPage> createState() =>
      _JustificationDetailPageState();
}

class _JustificationDetailPageState extends State<JustificationDetailPage> {
  final _cubit = GetIt.I.get<JustificationDetailCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getDetail(widget.id ?? 0);
  }

  Color _statusColor(int id) {
    switch (id) {
      case 1:
        return Colors.orange;
      case 11:
        return Colors.green;
      case 14:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JustificationDetailCubit, JustificationDetailState>(
      bloc: _cubit,
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.appBG2,
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: MyAppBar(
                titleAppbar: "Chi tiết yêu cầu MS",
                haveBackButton: true,
                haveActionButton: true,
                iconPathAsset: AppAssets.icNotificationBell,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    children: [
                      _contentCard(state),
                      const SizedBox(height: 20),
                      _actionButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _contentCard(JustificationDetailState state) {
    final e = state.detail;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: state.loadStatus == LoadStatus.LOADING || e == null
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              children: [
                _row("Nhân viên", "1"),
                const CustomDashView(),

                _row("Ca làm việc", "HC"),
                const CustomDashView(),

                _row("Phòng ban", "1"),
                const CustomDashView(),

                _row("Loại lý do", "Cá nhân"),
                const CustomDashView(),

                _row("Ngày", e.fromDate ?? ""),
                const SizedBox(height: 12),
                _dashedBlueBox(),
                const SizedBox(height: 12),
                _row("Ghi chú", e.reason ?? ""),
                const CustomDashView(),

                _statusRow(e.statusId),
                const CustomDashView(),

                _row("Người tạo", "1"),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _statusRow(int id) {
    final color = _statusColor(id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
            flex: 4,
            child: Text(
              "Trạng thái",
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Nháp",
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


Widget _dashedBlueBox() {
  return DashedBorderBox(
    radius: 12,
    color: const Color(0xFF3B82F6),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _row("Hình thức", "Đi muộn"),
          const CustomDashView(),
          _row("Số giờ", "01:30"),
        ],
      ),
    ),
  );
}



  Widget _actionButtons() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              mainText: "Xóa",
              type: PrimaryButtonType.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              mainText: "Cập nhật",
              type: PrimaryButtonType.primary,
              callback: () {},
            ),
          ),
        ],
      ),
    );
  }
}
