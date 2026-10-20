import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/discipline_chart_card_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn "Đánh giá kỷ luật" — chi tiết Dashboard, giao diện tối (v2).
///
/// Bản gốc: `lib/app/features/ui/dashboard/discipline_evaluation_detail.dart`
/// (+ `DisciplineEvaluationDetailCard` trong
/// `widgets/discipline_evaluation_detail_card.dart`). Giữ nguyên
/// [DashboardCubit] qua GetIt và điều hướng sang trang thông báo.
class DisciplineEvaluationDetailV2 extends StatefulWidget {
  const DisciplineEvaluationDetailV2({super.key});

  @override
  State<DisciplineEvaluationDetailV2> createState() =>
      _DisciplineEvaluationDetailV2State();
}

class _DisciplineEvaluationDetailV2State
    extends State<DisciplineEvaluationDetailV2> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  void _goNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: AppTokensV2.bgDeep,
        body: AmbientBackgroundV2(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: StaggerRevealV2(index: 0, child: _topBar(s)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: StaggerRevealV2(
                      index: 1,
                      child: GlassCardV2(
                        child: const DisciplineChartCardV2(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.appraisal_discipline_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNotification,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              size: 19, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }
}
