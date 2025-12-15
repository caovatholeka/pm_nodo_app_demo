import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/justification/widgets/justification_detail_body.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class JustificationDetail extends StatefulWidget {
  const JustificationDetail({super.key});

  @override
  State<JustificationDetail> createState() => _JustificationDetailState();
}

class _JustificationDetailState extends State<JustificationDetail> {
  @override
  Widget build(BuildContext context) {
    const statusId = 1;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: MyAppBar(
        titleAppbar: "Chi tiết yêu cầu nghỉ phép",
        haveBackButton: true,
        haveActionButton: true,
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: () {},
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.appBG2,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      child: Column(
                        children: const [
                          JustificationDetailBody(statusId: statusId),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
