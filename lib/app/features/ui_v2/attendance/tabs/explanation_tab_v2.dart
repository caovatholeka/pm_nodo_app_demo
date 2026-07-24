import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/attendance_tab/attendance_tab.dart'
    show YearMonthPicker;
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/send_invalid_page.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/generated/l10n.dart';

import '../widget/explanation_item_v2.dart';

/// Bản tối (v2) của [ExplanationTab]
/// (`lib/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_tab.dart`).
///
/// Cùng constructor (không tham số), tái dùng nguyên [ExplanationCubit] qua
/// GetIt. Hành vi giữ nguyên: nạp danh sách giải trình theo tháng ở
/// initState, đổi tháng/năm qua picker hoặc mũi tên, bấm 1 mục để điều hướng
/// sang [SendInvalidPage] (bản cũ, không đổi), refresh danh sách khi quay về.
class ExplanationTabV2 extends StatefulWidget {
  const ExplanationTabV2({super.key});

  @override
  State<ExplanationTabV2> createState() => _ExplanationTabV2State();
}

class _ExplanationTabV2State extends State<ExplanationTabV2> {
  final TextEditingController _reasonController = TextEditingController();
  final _cubit = GetIt.I.get<ExplanationCubit>();

  @override
  void initState() {
    _cubit.setYearMonth(DateTime.now().year, DateTime.now().month);
    super.initState();
    _cubit.getListWorkEntries();

    _reasonController.addListener(() {
      final text = _reasonController.text.trim();
      _cubit.updateReason(text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future _onRefresh() async {
    _cubit.getListWorkEntries();
  }

  Future<void> _sendInvalid(WorkEntryEntity entity) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SendInvalidPage(workEntryEntity: entity)),
    );

    if (result != null && result) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<ExplanationCubit, ExplanationState>(
      bloc: _cubit,
      listener: (context, state) {
        try {
          if (state.submitSuccess == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              try {
                showDialog(
                  context: context,
                  builder: (_) => CustomDialog(
                    iconPath: AppAssets.ic_done,
                    title: s.success,
                    content: s.explan_sendSussces,
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              } catch (e, st) {
                debugPrint('Error showing dialog: $e\n$st');
              }
              try {
                _reasonController.clear();
              } catch (e, st) {
                debugPrint('Error clearing controller: $e\n$st');
              }
              Future.microtask(() {
                try {
                  _cubit.resetSubmitSuccess();
                } catch (e, st) {
                  debugPrint('Error resetting submitSuccess: $e\n$st');
                }
              });
            });
          }
        } catch (e, st) {
          debugPrint('Listener caught error: $e\n$st');
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: _workEntriesWidget,
        );
      },
    );
  }

  // danh sach giai trinh cong
  get _workEntriesWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYearMonthDropdown(),
        _listWorkEntries,
      ],
    );
  }

  // danh sách giải trình
  get _listWorkEntries {
    return BlocBuilder<ExplanationCubit, ExplanationState>(
        bloc: _cubit,
        buildWhen: (prev, cur) =>
            prev.loadStatus != cur.loadStatus ||
            prev.listWorkEntries != cur.listWorkEntries,
        builder: (context, state) {
          return state.loadStatus == LoadStatus.LOADING
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTokensV2.accent, strokeWidth: 2.2),
                )
              : ((state.listWorkEntries ?? []).isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppTokensV2.accent,
                      backgroundColor: AppTokensV2.bgTop,
                      child: ListView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          shrinkWrap: true,
                          controller: ScrollController(),
                          itemCount: (state.listWorkEntries ?? []).length,
                          itemBuilder: (context, index) {
                            WorkEntryEntity entity =
                                (state.listWorkEntries ?? [])[index];
                            return ExplanationItemV2(
                              workEntryEntity: entity,
                              onExplain: () async {
                                await _sendInvalid(entity);
                              },
                            );
                          }),
                    )
                  : Center(
                      child: Text(S.of(context).bt_empty,
                          style: AppTokensV2.caption),
                    ).paddingOnly(top: 30));
        });
  }

  // chon time
  Widget _buildYearMonthDropdown() {
    final s = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async {
            final s = _cubit.state;
            await _showYearMonthPicker(
              context: context,
              defaultValue: DateTime(s.selectedYear ?? DateTime.now().year,
                  s.selectedMonth ?? DateTime.now().month, 1),
              onConfirm: (month, year) {
                _cubit.setYearMonth(int.parse(year), int.parse(month));
                _cubit.getListWorkEntries();
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTokensV2.accentGradient,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: BlocBuilder<ExplanationCubit, ExplanationState>(
                bloc: _cubit,
                buildWhen: (prev, cur) =>
                    prev.selectedMonth != cur.selectedMonth ||
                    prev.selectedYear != cur.selectedYear,
                builder: (context, state) {
                  return Text(
                    "${s.work_data_monthYear} ${state.selectedMonth}, ${state.selectedYear}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  );
                }),
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                _shiftMonth(-1);
              },
              child: Container(
                width: 30,
                height: 30,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTokensV2.surfaceStrong),
                child: InkWell(
                  onTap: () {
                    _shiftMonth(-1);
                  },
                  child: const Center(
                      child: Icon(Icons.arrow_back_ios,
                          color: AppTokensV2.fgSoft, size: 16)),
                ),
              ).paddingOnly(right: 12),
            ),
            InkWell(
              onTap: () {
                _shiftMonth(1);
              },
              child: Container(
                width: 30,
                height: 30,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTokensV2.surfaceStrong),
                child: InkWell(
                  onTap: () {
                    _shiftMonth(1);
                  },
                  child: const Center(
                      child: Icon(Icons.arrow_forward_ios,
                          color: AppTokensV2.fgSoft, size: 16)),
                ).paddingOnly(right: 4),
              ),
            )
          ],
        )
      ],
    );
  }

  Future<void> _showYearMonthPicker({
    required BuildContext context,
    DateTime? defaultValue,
    required void Function(String month, String year) onConfirm,
  }) async {
    final now = DateTime.now();
    final initial = defaultValue ?? DateTime(now.year, now.month, 1);

    DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: LocaleType.vi,
      theme: const DatePickerTheme(
        backgroundColor: AppTokensV2.bgTop,
        itemStyle: TextStyle(color: AppTokensV2.fg, fontSize: 18),
        doneStyle: TextStyle(color: AppTokensV2.accent, fontSize: 16),
        cancelStyle: TextStyle(color: AppTokensV2.fgMuted, fontSize: 16),
      ),
      pickerModel: YearMonthPicker(
        currentTime: initial,
        minTime: DateTime(2015, 1, 1),
        maxTime: DateTime(2035, 12, 31),
        locale: LocaleType.vi,
      ),
      onConfirm: (dt) {
        final y = dt.year.toString();
        final m = dt.month.toString().padLeft(2, '0');
        onConfirm(m, y);
      },
    );
  }

  // on change month
  void _shiftMonth(int delta) {
    final s = _cubit.state;
    int y = s.selectedYear ?? DateTime.now().year;
    int m = (s.selectedMonth ?? DateTime.now().month) + delta;

    if (m > 12) {
      m = 1;
      y += 1;
    }
    if (m < 1) {
      m = 12;
      y -= 1;
    }

    _cubit.setYearMonth(y, m);
    _cubit.getListWorkEntries();
  }
}
