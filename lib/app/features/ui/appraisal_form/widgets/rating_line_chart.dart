import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';

class RatingSummaryCard extends StatefulWidget {
  final VoidCallback? onTap;

  const RatingSummaryCard({
    super.key,
    this.onTap,
  });

  @override
  State<RatingSummaryCard> createState() => _RatingSummaryCardState();
}

class _RatingSummaryCardState extends State<RatingSummaryCard> {
  DateTime _selectedDate = DateTime.now();

  String get _monthLabel =>
      DateFormat("'Tháng' MM/yyyy", 'vi_VN').format(_selectedDate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getDisciplineEvaluation(
            _selectedDate.month,
            year: _selectedDate.year,
          );
    });
  }

  void _pickMonth() {
    int tempYear = _selectedDate.year;
    int tempMonth = _selectedDate.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final nextDate = DateTime(tempYear, tempMonth);

                        setState(() {
                          _selectedDate = nextDate;
                        });

                        context.read<DashboardCubit>().getDisciplineEvaluation(
                              nextDate.month,
                              year: nextDate.year,
                            );

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          color: Color(0xFF2E87FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: tempYear - 2020,
                        ),
                        onSelectedItemChanged: (index) {
                          tempYear = 2020 + index;
                        },
                        children: List.generate(
                          20,
                          (i) => Center(
                            child: Text(
                              (2020 + i).toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: tempMonth - 1,
                        ),
                        onSelectedItemChanged: (index) {
                          tempMonth = index + 1;
                        },
                        children: List.generate(
                          12,
                          (i) => Center(
                            child: Text(
                              'Tháng ${(i + 1).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.icUserRating,
                      width: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Đánh giá nề nếp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _pickMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(AppAssets.icCalendar, width: 14),
                        const SizedBox(width: 6),
                        Text(
                          _monthLabel,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state.disciplineStatus == LoadStatus.LOADING) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }

                if (state.disciplineStatus == LoadStatus.FAILURE) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: const Text(
                      'Không tải được dữ liệu',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final data = state.disciplineEvaluation;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryItem(
                          value: '${data?.onTimePercent ?? 0}%',
                          label: 'Đúng giờ',
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      const _Divider(),
                      Expanded(
                        child: _SummaryItem(
                          value: '${data?.absentCount ?? 0}',
                          label: 'Vắng mặt',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const _Divider(),
                      Expanded(
                        child: _SummaryItem(
                          value: '${data?.lateEarlyCount ?? 0}',
                          label: 'Muộn/Sớm',
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: const Color(0xFFE5E7EB));
  }
}
