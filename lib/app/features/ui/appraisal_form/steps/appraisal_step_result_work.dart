import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../data/models/entities/task_line_id_entity.dart';
import '../widgets/dot_devider_painter.dart';

class AppraisalStepResultWork extends StatelessWidget {
  final List<TaskLineIdEntity>? listTask;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> rateControllers;
  final List<TextEditingController> evidenceControllers;
  final void Function(int taskIndex, int ratingIndex, int value) onRate;
  final void Function(int taskIndex, String value) onNameChanged;
  final void Function(int taskIndex, String value) onTaskRateChanged;

  final bool readOnly;
  final bool isLeaderReview;

  const AppraisalStepResultWork({
    super.key,
    this.listTask,
    required this.nameControllers,
    required this.rateControllers,
    required this.evidenceControllers,
    required this.onRate,
    required this.onNameChanged,
    required this.onTaskRateChanged,
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

  TextEditingController _controllerAt(
    List<TextEditingController> controllers,
    int index,
  ) {
    while (controllers.length <= index) {
      controllers.add(TextEditingController());
    }
    return controllers[index];
  }

  TextEditingController _evidenceController(TaskLineIdEntity task, int index) {
    final controller = _controllerAt(evidenceControllers, index);
    if (controller.text.isEmpty) {
      controller.text = _taskEvidence(task);
    }
    return controller;
  }

  TextEditingController _nameController(TaskLineIdEntity task, int index) {
    final controller = _controllerAt(nameControllers, index);
    if (controller.text.isEmpty) {
      controller.text = task.name ?? "";
    }
    return controller;
  }

  TextEditingController _rateController(TaskLineIdEntity task, int index) {
    final controller = _controllerAt(rateControllers, index);
    if (controller.text.isEmpty) {
      controller.text = (task.rate ?? 0).toString();
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
                  Text(
                    s.appraisal_step_result_work,
                    style: const TextStyle(
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
                color:
                    isLeaderReview
                        ? const Color(0xFFE5E0F0)
                        : const Color(0xFFF7FFF6),
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
                            isLeaderReview
                                ? const Color(0xFF7030A0)
                                : const Color(0xFF10B981),
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
                        s.appraisal_step_result_work_tasks,
                        style: TextStyle(
                          color:
                              isLeaderReview
                                  ? const Color(0xFF7030A0)
                                  : const Color(0xFF065F46),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  isLeaderReview
                      ? Text(
                        s.appraisal_step_direct_manager_rate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.themeDarkDark,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                      : Text(
                        s.appraisal_rating_note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                ],
              ),
            ),
            Column(
              children:
                  List.generate((listTask ?? []).length, (i) {
                    final task = (listTask ?? [])[i];

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isLeaderReview
                                    ? const Color(0xFFE5E0F0)
                                    : const Color(0xFFF7FFF6),
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
                                  title: s.appraisal_task_done,
                                  hintText: s.appraisal_task_done_hint,
                                  controller: _nameController(task, i),
                                  readOnly: readOnly,
                                  onChange: (value) => onNameChanged(i, value),
                                  isRequiredField: true,
                                  fillBgColor: Colors.transparent,
                                ),
                                const SizedBox(height: 12),
                                InputTextField(
                                  title: s.appraisal_weight_percent,
                                  hintText: s.appraisal_weight_percent_hint,
                                  controller: _rateController(task, i),
                                  readOnly: readOnly,
                                  inputType: TextInputType.number,
                                  onChange:
                                      (value) => onTaskRateChanged(i, value),
                                  isRequiredField: true,
                                  fillBgColor: Colors.transparent,
                                ),
                                const SizedBox(height: 16),
                                _rating(
                                  s.appraisal_metric_volume_numbered,
                                  i,
                                  0,
                                  _taskRating(task, 0),
                                ),
                                _rating(
                                  s.appraisal_metric_quality_numbered,
                                  i,
                                  1,
                                  _taskRating(task, 1),
                                ),
                                _rating(
                                  s.appraisal_metric_progress_numbered,
                                  i,
                                  2,
                                  _taskRating(task, 2),
                                ),
                                const SizedBox(height: 12),
                                isLeaderReview
                                    ? InputTextField(
                                      title: s.appraisal_adjustment_feedback,
                                      hintText: '',
                                      controller: _evidenceController(task, i),
                                      readOnly: readOnly,
                                      isRequiredField: true,
                                      fillBgColor: Colors.transparent,
                                    )
                                    : InputTextField(
                                      title: s.appraisal_evidence,
                                      hintText: s.appraisal_evidence_hint,
                                      controller: _evidenceController(task, i),
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
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: DotDividerPainter(
                                color:
                                    isLeaderReview
                                        ? const Color(0xFFE5E0F0)
                                        : const Color(0xFFD1FAE5),
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

  Widget _rating(String title, int taskIndex, int ratingIndex, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 35,
            children: List.generate(5, (i) {
              final filled = i < value;

              return InkWell(
                onTap:
                    readOnly
                        ? null
                        : () => onRate(taskIndex, ratingIndex, i + 1),
                child: SvgPicture.asset(
                  AppAssets.icStar,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    filled ? const Color(0xFFFFCB45) : const Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
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
