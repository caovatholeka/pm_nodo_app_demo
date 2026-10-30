import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../data/models/entities/task_line_id_entity.dart';
import '../../../ui/appraisal_form/widgets/dot_devider_painter.dart';
import '../widgets/appraisal_help_tooltip_v2.dart';

/// Bản tối (v2) của [AppraisalStepResultWork]
/// (`lib/app/features/ui/appraisal_form/steps/appraisal_step_result_work.dart`).
/// Cùng constructor/callback, cùng tính toán rating/controller — chỉ đổi màu
/// nền/chữ sang tông tối. Nhãn tự-đánh-giá dùng tông xanh (success), nhãn
/// cấp trên duyệt (`isLeaderReview`) dùng tông tím-chàm (accent2) để giữ ý
/// nghĩa phân biệt hai luồng như bản gốc.
class AppraisalStepResultWorkV2 extends StatelessWidget {
  final List<TaskLineIdEntity>? listTask;
  final List<TextEditingController> nameControllers;
  final List<TextEditingController> rateControllers;
  final List<TextEditingController> evidenceControllers;
  final void Function(int taskIndex, int ratingIndex, int value) onRate;
  final void Function(int taskIndex, String value) onNameChanged;
  final void Function(int taskIndex, String value) onTaskRateChanged;
  final void Function(int taskIndex, String value)? onEvidenceChanged;
  final VoidCallback? onAddCriteria;
  // null = không cho xoá (chỉ còn số đầu việc tối thiểu, hoặc chế độ chỉ xem)
  final void Function(int index)? onRemoveItem;
  final Future<void> Function(int index)? onItemTap;
  final String Function(int index)? hrNoteText;
  final String Function(int index)? hrStatusText;

  final bool readOnly;
  final bool isLeaderReview;
  final bool autoShowHelp;

  const AppraisalStepResultWorkV2({
    super.key,
    this.listTask,
    required this.nameControllers,
    required this.rateControllers,
    required this.evidenceControllers,
    required this.onRate,
    required this.onNameChanged,
    required this.onTaskRateChanged,
    this.onEvidenceChanged,
    this.onAddCriteria,
    this.onRemoveItem,
    this.onItemTap,
    this.hrNoteText,
    this.hrStatusText,
    this.readOnly = false,
    this.isLeaderReview = false,
    this.autoShowHelp = false,
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
    if (controller.text.isEmpty && task.rate != null) {
      controller.text = task.rate.toString();
    }
    return controller;
  }

  static TextStyle _fieldStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppTokensV2.fg,
  );

  Color get _accent =>
      isLeaderReview ? AppTokensV2.accent2 : AppTokensV2.success;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.appraisal_step_result_work, style: AppTokensV2.body),
                  AppraisalHelpTooltipV2(
                    message: s.v2_appraisal_result_work_help,
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: AppTokensV2.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: _accent,
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
                          color: _accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  isLeaderReview
                      ? Text(
                        s.appraisal_step_direct_manager_rate,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTokensV2.fgSoft,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                      : Text(
                        s.appraisal_rating_note,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTokensV2.accent,
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

                    final itemContent = Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTokensV2.surface,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Đánh số để khớp với thông báo "Đầu việc N: chưa nhập ..."
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.v2_appraisal_task_item(i + 1),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _accent,
                                        ),
                                      ),
                                    ),
                                    if (!readOnly && onRemoveItem != null)
                                      IconButton(
                                        onPressed: () => onRemoveItem!(i),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: AppTokensV2.danger,
                                        ),
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                InputTextField(
                                  v2Style: true,
                                  title: s.appraisal_task_done,
                                  hintText: s.appraisal_task_done_hint,
                                  controller: _nameController(task, i),
                                  readOnly: readOnly,
                                  maxLength: InputLimits.appraisalTitle,
                                  buildCounter: inputCounterV2(always: false),
                                  onChange: (value) => onNameChanged(i, value),
                                  isRequiredField: true,
                                  fillBgColor: AppTokensV2.surfaceStrong,
                                  style: _fieldStyle,
                                ),
                                const SizedBox(height: 12),
                                InputTextField(
                                  v2Style: true,
                                  title: s.appraisal_weight_percent,
                                  hintText: s.appraisal_weight_percent_hint,
                                  controller: _rateController(task, i),
                                  readOnly: readOnly,
                                  inputType: TextInputType.number,
                                  onChange:
                                      (value) => onTaskRateChanged(i, value),
                                  isRequiredField: true,
                                  fillBgColor: AppTokensV2.surfaceStrong,
                                  style: _fieldStyle,
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
                                      v2Style: true,
                                      title: s.appraisal_adjustment_feedback,
                                      hintText: '',
                                      controller: _evidenceController(task, i),
                                      readOnly: readOnly,
                                      maxLength: InputLimits.appraisalNote,
                                      buildCounter: inputCounterV2(
                                        always: false,
                                      ),
                                      isRequiredField: true,
                                      fillBgColor: AppTokensV2.surfaceStrong,
                                      style: _fieldStyle,
                                      onChange:
                                          onEvidenceChanged == null
                                              ? null
                                              : (value) =>
                                                  onEvidenceChanged!(i, value),
                                    )
                                    : InputTextField(
                                      v2Style: true,
                                      title: s.appraisal_evidence,
                                      hintText: s.appraisal_evidence_hint,
                                      controller: _evidenceController(task, i),
                                      readOnly: readOnly,
                                      maxLength: InputLimits.appraisalNote,
                                      buildCounter: inputCounterV2(
                                        always: false,
                                      ),
                                      isRequiredField: true,
                                      fillBgColor: AppTokensV2.surfaceStrong,
                                      style: _fieldStyle,
                                      onChange:
                                          onEvidenceChanged == null
                                              ? null
                                              : (value) =>
                                                  onEvidenceChanged!(i, value),
                                    ),
                                if (hrNoteText != null &&
                                    hrStatusText != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 1,
                                    color: AppTokensV2.border,
                                  ),
                                  const SizedBox(height: 12),
                                  InputTextField(
                                    v2Style: true,
                                    title: s.v2_appraisal_hr_opinion,
                                    hintText: '',
                                    initialValue: hrNoteText!(i),
                                    readOnly: true,
                                    enable: false,
                                    isRequiredField: false,
                                    fillBgColor: AppTokensV2.surface,
                                    style: _fieldStyle,
                                  ),
                                  const SizedBox(height: 12),
                                  InputTextField(
                                    v2Style: true,
                                    title: s.employee_advanced_status,
                                    hintText: '',
                                    initialValue: hrStatusText!(i),
                                    readOnly: true,
                                    enable: false,
                                    isRequiredField: false,
                                    fillBgColor: AppTokensV2.surface,
                                    style: _fieldStyle,
                                  ),
                                ],
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
                                color: AppTokensV2.border,
                              ),
                            ),
                          ),
                      ],
                    ).paddingOnly(bottom: 16);

                    if (onItemTap == null) {
                      return itemContent;
                    }

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onItemTap!(i),
                        child: IgnorePointer(
                          ignoring: true,
                          child: itemContent,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            if (onAddCriteria != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: DashedBorderBox(
                  radius: 14,
                  color: AppTokensV2.accent,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onAddCriteria,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppTokensV2.accent, size: 22),
                            SizedBox(width: 8),
                            Text(
                              s.v2_appraisal_add_criteria,
                              style: TextStyle(
                                color: AppTokensV2.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rating(String title, int taskIndex, int ratingIndex, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTokensV2.fg,
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
                onTap:
                    readOnly
                        ? null
                        : () => onRate(taskIndex, ratingIndex, i + 1),
                child: SvgPicture.asset(
                  AppAssets.icStar,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                    filled ? AppTokensV2.warn : AppTokensV2.fgMuted,
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
