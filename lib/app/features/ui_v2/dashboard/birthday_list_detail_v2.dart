import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/birthday_list_tile_v2.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/month_picker_sheet_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn "Sinh nhật tháng" — chi tiết Dashboard, giao diện tối (v2).
///
/// Bản gốc: `lib/app/features/ui/dashboard/birthday_list_detail.dart`
/// (+ `BirthdayDetailSection` trong `widgets/birthday_card.dart`).
/// Giữ nguyên [DashboardCubit] qua GetIt, cùng lời gọi
/// `getBirthdaysThisMonth` ở initState (postFrameCallback) và khi đổi tháng.
class BirthdayListDetailV2 extends StatefulWidget {
  const BirthdayListDetailV2({super.key});

  @override
  State<BirthdayListDetailV2> createState() => _BirthdayListDetailV2State();
}

class _BirthdayListDetailV2State extends State<BirthdayListDetailV2> {
  final _cubit = GetIt.I.get<DashboardCubit>();
  int _selectedMonth = DateTime.now().month;

  String _monthLabel(S s) =>
      '${s.month} ${_selectedMonth.toString().padLeft(2, '0')}/${DateTime.now().year}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getBirthdaysThisMonth(_selectedMonth);
    });
  }

  Future<void> _pickMonth() async {
    HapticFeedback.selectionClick();
    final picked = await showMonthPickerV2(context, initialMonth: _selectedMonth);
    if (picked == null) return;
    setState(() => _selectedMonth = picked);
    _cubit.getBirthdaysThisMonth(picked);
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _monthSelector(s),
                            const SizedBox(height: 14),
                            _content(s),
                          ],
                        ),
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
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.appraisal_birthday_month_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _monthSelector(S s) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickMonth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          border: Border.all(color: AppTokensV2.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 15, color: AppTokensV2.fgMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_monthLabel(s), style: AppTokensV2.body),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: AppTokensV2.fgMuted),
          ],
        ),
      ),
    );
  }

  Widget _content(S s) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.birthdayStatus != current.birthdayStatus ||
          previous.birthdays != current.birthdays,
      builder: (context, state) {
        if (state.birthdayStatus == LoadStatus.LOADING &&
            state.birthdays.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppTokensV2.accent, strokeWidth: 2.2),
            ),
          );
        }

        if (state.birthdayStatus == LoadStatus.FAILURE &&
            state.birthdays.isEmpty) {
          return _emptyState(s.appraisal_load_failed);
        }

        if (state.birthdays.isEmpty) {
          return _emptyState(s.appraisal_no_birthdays_this_month);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.birthdays.length,
          separatorBuilder: (_, __) => Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Divider(height: 1, color: AppTokensV2.border),
          ),
          itemBuilder: (context, index) {
            return BirthdayListTileV2(employee: state.birthdays[index]);
          },
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cake_outlined,
                size: 40, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text(message, style: AppTokensV2.captionStrong),
          ],
        ),
      ),
    );
  }
}
