import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../ui/appraisal_form/widgets/dot_devider_painter.dart';
import '../widgets/appraisal_help_tooltip_v2.dart';

/// Bản tối (v2) của [AppraisalStepResponsibility]
/// (`lib/app/features/ui/appraisal_form/steps/appraisal_step_responsibility.dart`).
/// Cùng constructor/callback, cùng hệ số & rating — chỉ đổi màu sang tông tối.
class AppraisalStepResponsibilityV2 extends StatelessWidget {
  static const List<double> _coefficients = [2, 2, 1.5, 2, 0.5];
  final List<ResponsiveIdEntity> responses;
  final List<TextEditingController> evidences;
  final void Function(int index, int value) onRate;
  final void Function(int index, String value)? onEvidenceChanged;
  final bool isLeaderReview;
  final bool readOnly;
  final Future<void> Function(int index)? onItemTap;
  final String Function(int index)? hrNoteText;
  final String Function(int index)? hrStatusText;
  final bool autoShowHelp;

  const AppraisalStepResponsibilityV2({
    super.key,
    required this.responses,
    required this.evidences,
    required this.onRate,
    this.onEvidenceChanged,
    this.isLeaderReview = false,
    this.readOnly = false,
    this.onItemTap,
    this.hrNoteText,
    this.hrStatusText,
    this.autoShowHelp = false,
  });

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  int _responseRating(ResponsiveIdEntity item) {
    return _toInt(isLeaderReview ? item.parentRatePoint : item.ratePoint);
  }

  double _coefficientAt(int index) {
    if (index < _coefficients.length) {
      return _coefficients[index];
    }
    return 2;
  }

  String _formatCoefficient(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  TextEditingController _responseEvidence(ResponsiveIdEntity item, int index) {
    final controller = evidences[index];
    if (controller.text.isEmpty) {
      controller.text =
          isLeaderReview ? (item.parentNote ?? '') : (item.note ?? '');
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.appraisal_step_responsibility, style: AppTokensV2.body),
                  AppraisalHelpTooltipV2(
                    message: s.v2_appraisal_self_assess_help,
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: AppTokensV2.surface,
                borderRadius: BorderRadius.circular(16),
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
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.appraisal_responsibility_criteria,
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLeaderReview
                        ? s.appraisal_step_direct_manager_rate
                        : s.appraisal_responsibility_description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTokensV2.fgSoft,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (responses.isNotEmpty) const SizedBox(height: 14),
                  Column(
                    children: List.generate(responses.length, (i) {
                      final item = responses[i];

                      final itemContent = Padding(
                        padding: EdgeInsets.only(
                          bottom: i == responses.length - 1 ? 0 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: AppTokensV2.fg,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: '• ',
                                    style: TextStyle(
                                      color: AppTokensV2.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: item.code ?? '',
                                    style: TextStyle(
                                      color: AppTokensV2.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' - ${item.name ?? ''}'),
                                  TextSpan(
                                    text:
                                        ' - ${s.appraisal_coefficient} ${_formatCoefficient(_coefficientAt(i))}',
                                    style: TextStyle(
                                      color: AppTokensV2.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              s.appraisal_score,
                              style: TextStyle(
                                color: AppTokensV2.fg,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 26,
                                children: List.generate(5, (j) {
                                  final filled = j < _responseRating(item);

                                  return InkWell(
                                    onTap:
                                        readOnly
                                            ? null
                                            : () => onRate(i, j + 1),
                                    child: SvgPicture.asset(
                                      AppAssets.icStar,
                                      width: 28,
                                      height: 28,
                                      colorFilter: ColorFilter.mode(
                                        filled
                                            ? AppTokensV2.warn
                                            : AppTokensV2.fgMuted,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              v2Style: true,
                              title:
                                  isLeaderReview
                                      ? s.v2_appraisal_adjust_feedback_title
                                      : s.v2_appraisal_state_pros_cons,
                              hintText:
                                  isLeaderReview
                                      ? s.v2_appraisal_adjust_feedback_hint
                                      : s.v2_appraisal_enter_evidence,
                              controller: _responseEvidence(item, i),
                              maxLine: 3,
                              maxLength: InputLimits.appraisalText,
                              buildCounter: inputCounterV2(),
                              isRequiredField: true,
                              readOnly: readOnly,
                              fillBgColor: AppTokensV2.surfaceStrong,
                              style: _fieldStyle,
                              onChange:
                                  onEvidenceChanged == null
                                      ? null
                                      : (value) => onEvidenceChanged!(i, value),
                            ),
                            if (hrNoteText != null && hrStatusText != null) ...[
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
                            if (i != responses.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DotDividerPainter(
                                    color: AppTokensV2.border,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );

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
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
