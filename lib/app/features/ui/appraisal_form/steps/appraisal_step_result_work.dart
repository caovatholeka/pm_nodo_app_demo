import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

import '../../../../data/models/entities/task_line_id_entity.dart';
import '../widgets/dot_devider_painter.dart';

class AppraisalStepResultWork extends StatelessWidget {
  final List<int> ratings;
  final void Function(int index, int value) onRate;

  final TextEditingController jobCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController evidenceCtrl;
  final List<TaskLineIdEntity>? listTask;

  final bool readOnly;
  final bool isLeaderReview;

  const AppraisalStepResultWork({
    super.key,
    this.listTask,
    required this.ratings,
    required this.onRate,
    required this.jobCtrl,
    required this.weightCtrl,
    required this.evidenceCtrl,
    this.readOnly = false,
    this.isLeaderReview = false,
  });

  int _toInt(dynamic v) {
    if (v == null) return 0;

    if (v is bool) {
      return v ? 1 : 0;
    }

    return int.tryParse(v.toString()) ?? 0;
  }

  int _taskRating(TaskLineIdEntity task, int ratingIndex) {
    if (isLeaderReview) {
      switch (ratingIndex) {
        case 0:
          return _toInt(task.parentVolume);
        case 1:
          return _toInt(task.parentQuality);
        case 2:
          return _toInt(task.parentProgress);
      }
    }

    switch (ratingIndex) {
      case 0:
        return _toInt(task.volume);
      case 1:
        return _toInt(task.quality);
      case 2:
        return _toInt(task.progress);
      default:
        return 0;
    }
  }

  String _taskEvidence(TaskLineIdEntity task) {
    if (isLeaderReview) {
      return task.parentNote ?? "";
    }

    if ((task.jiraKey ?? "").isNotEmpty) {
      return task.jiraKey ?? "";
    }

    return task.note ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isLeaderReview ? const Color(0xFFE5E0F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'I. Kết quả công việc (70%)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SvgPicture.asset(AppAssets.icQuestion, width: 20),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF10B981),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Các việc đã làm',
                        style: TextStyle(
                          color: isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF065F46),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  isLeaderReview
                      ? Text(
                          'Cấp trên trực tiếp đánh giá (Max = 5 điểm)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.themeDarkDark,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : const Text(
                          'Lưu ý: Đọc kỹ sử dụng trước khi dùng. Đánh giá theo thang điểm 1-5. (Dựa theo hướng dẫn cho sẵn)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ],
              ),
            ),
            Column(
              children: List.generate((listTask ?? []).length, (i) {
                final task = (listTask ?? [])[i];

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputTextField(
                              title: 'Công việc đã làm',
                              hintText: 'Nhập công việc đã làm',
                              controller: TextEditingController(text: task.name),
                              readOnly: readOnly,
                              isRequiredField: true,
                              fillBgColor: Colors.transparent,
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              title: 'Tỷ trọng %',
                              hintText: 'Nhập % (0-100)',
                              controller: TextEditingController(text: (task.rate ?? 0).toString()),
                              readOnly: readOnly,
                              isRequiredField: true,
                              fillBgColor: Colors.transparent,
                            ),
                            const SizedBox(height: 16),
                            _rating('1. Khối lượng', 0, _taskRating(task, 0)),
                            _rating('2. Chất lượng', 1, _taskRating(task, 1)),
                            _rating('3. Tiến độ', 2, _taskRating(task, 2)),
                            const SizedBox(height: 12),
                            isLeaderReview
                                ? InputTextField(
                                    title: 'Góp ý điều chỉnh',
                                    hintText: '',
                                    controller: TextEditingController(text: _taskEvidence(task)),
                                    readOnly: readOnly,
                                    isRequiredField: true,
                                    fillBgColor: Colors.transparent,
                                  )
                                : InputTextField(
                                    title: 'Dẫn chứng',
                                    hintText: 'Nhập dẫn chứng...',
                                    controller: TextEditingController(text: _taskEvidence(task)),
                                    readOnly: readOnly,
                                    isRequiredField: true,
                                    fillBgColor: Colors.transparent,
                                  ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (i != (listTask ?? []).length - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: DotDividerPainter(
                            color:
                                isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFD1FAE5),
                          ),
                        ),
                      ),
                  ],
                ).paddingOnly(bottom: 16);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rating(String title, int index, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 35,
            children: List.generate(5, (i) {
              final filled = i < value;

              return InkWell(
                onTap: readOnly ? null : () => onRate(index, i + 1),
                child: SvgPicture.asset(
                  AppAssets.icStar,
                  width: 30,
                  height: 30,
                  color: filled ? const Color(0xFFFFCB45) : const Color(0xFF64748B),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
