import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../widgets/dot_devider_painter.dart';

class AppraisalStepResponsibility extends StatelessWidget {
  final List<ResponsiveIdEntity> responses;
  final List<int> ratings;
  final List<TextEditingController> evidences;
  final void Function(int index, int value) onRate;
  final bool isLeaderReview;

  const AppraisalStepResponsibility({
    super.key,
    required this.responses,
    required this.ratings,
    required this.evidences,
    required this.onRate,
    this.isLeaderReview = false,
  });

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  int _responseRating(ResponsiveIdEntity item, int index) {
    final currentRating = index < ratings.length ? ratings[index] : 0;
    if (currentRating > 0) return currentRating;
    return _toInt(isLeaderReview ? item.parentRatePoint : item.ratePoint);
  }

  TextEditingController _responseEvidence(ResponsiveIdEntity item, int index) {
    final controller = evidences[index];
    if (controller.text.isEmpty) {
      controller.text =
          isLeaderReview ? (item.parentNote ?? '') : (item.note ?? '');
    }
    return controller;
  }

  Color get _sectionBg =>
      isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6);
  Color get _accent =>
      isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF10B981);
  Color get _titleColor =>
      isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF065F46);
  Color get _dividerColor =>
      isLeaderReview ? const Color(0xFFD8CAE8) : const Color(0xFFD1FAE5);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.appraisal_step_responsibility,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SvgPicture.asset(AppAssets.icQuestion, width: 20),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: _sectionBg,
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
                            color: _titleColor,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.themeDarkDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (responses.isNotEmpty) const SizedBox(height: 14),
                  Column(
                    children: List.generate(responses.length, (i) {
                      final item = responses[i];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == responses.length - 1 ? 0 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(
                                    text: '• ',
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: item.code ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' - ${item.name ?? ''}'),
                                  TextSpan(
                                    text: ' - ${s.appraisal_coefficient} 2',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              s.appraisal_score,
                              style: const TextStyle(
                                color: Color(0xFF111827),
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
                                  final filled = j < _responseRating(item, i);

                                  return InkWell(
                                    onTap: () => onRate(i, j + 1),
                                    child: SvgPicture.asset(
                                      AppAssets.icStar,
                                      width: 28,
                                      height: 28,
                                      color:
                                          filled
                                              ? const Color(0xFFFFB800)
                                              : const Color(0xFF64748B),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              title: s.appraisal_comment_detail,
                              hintText: s.appraisal_evidence_hint,
                              controller: _responseEvidence(item, i),
                              maxLine: 3,
                              isRequiredField: true,
                              readOnly: true,
                              fillBgColor: Colors.white.withValues(alpha: 0.65),
                            ),
                            if (i != responses.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DotDividerPainter(
                                    color: _dividerColor,
                                  ),
                                ),
                              ),
                          ],
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
