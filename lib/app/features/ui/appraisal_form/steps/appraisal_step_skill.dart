import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/entities/skill_id_entity.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/appraisal_help_tooltip.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

class AppraisalStepSkill extends StatelessWidget {
  static const List<double> _coefficients = [1, 1, 0.5, 0.5, 1];
  final List<SkillIdEntity> skills;
  final List<TextEditingController> evidences;
  final void Function(int index, int value) onRate;
  final void Function(int index, String value)? onEvidenceChanged;
  final bool isLeaderReview;
  final bool readOnly;
  final Future<void> Function(int index)? onItemTap;
  final String Function(int index)? hrNoteText;
  final String Function(int index)? hrStatusText;
  final bool autoShowHelp;

  const AppraisalStepSkill({
    super.key,
    required this.skills,
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

  int _skillRating(SkillIdEntity skill, int index) {
    return _toInt(isLeaderReview ? skill.parentRatePoint : skill.ratePoint);
  }

  double _coefficientAt(int index) {
    if (index < _coefficients.length) {
      return _coefficients[index];
    }
    return 1;
  }

  String _formatCoefficient(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  TextEditingController _skillEvidence(SkillIdEntity skill, int index) {
    final controller = evidences[index];
    if (controller.text.isEmpty) {
      controller.text =
          isLeaderReview ? (skill.parentNote ?? '') : (skill.note ?? '');
    }
    return controller;
  }

  Color get _sectionBg =>
      isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6);
  Color get _accent =>
      isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF0B6F2F);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EEF8)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.appraisal_step_skill,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  AppraisalHelpTooltip(
                    message: 'Tự đánh giá mình theo các đầu mục, ghi rõ những gì được, chưa được',
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: _sectionBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.appraisal_skill_criteria,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    isLeaderReview
                                        ? const Color(0xFF7030A0)
                                        : const Color(0xFF0B6F2F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.appraisal_skill_description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.themeDarkDark,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (skills.isNotEmpty) const SizedBox(height: 14),
                  Column(
                    children: List.generate(skills.length, (i) {
                      final skill = skills[i];

                      final itemContent = Padding(
                        padding: EdgeInsets.only(
                          bottom: i == skills.length - 1 ? 0 : 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '•  ',
                                  style: TextStyle(color: Color(0xFF0B6FDF)),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 13),
                                      children: [
                                        TextSpan(
                                          text: '${skill.code ?? ''} - ',
                                          style: const TextStyle(
                                            color: Color(0xFF0B6FDF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: skill.name ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF0B6FDF),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' - ${s.appraisal_coefficient} ${_formatCoefficient(_coefficientAt(i))}',
                                          style: const TextStyle(
                                            color: Color(0xFF0B6FDF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  '* ',
                                  style: TextStyle(color: Color(0xFFEF4444)),
                                ),
                                Text(
                                  s.appraisal_score,
                                  style: const TextStyle(
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 22,
                                children: List.generate(5, (j) {
                                  final filled = j < _skillRating(skill, i);

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
                                            ? const Color(0xFFFFB800)
                                            : const Color(0xFF94A3B8),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              title:
                                  isLeaderReview
                                      ? 'Góp ý điều chỉnh với các điểm chưa được'
                                      : 'Ghi rõ những gì được, chưa được',
                              hintText:
                                  isLeaderReview
                                      ? 'Góp ý điều chỉnh đối với các điểm chưa được'
                                      : 'Nhập dẫn chứng',
                              controller: _skillEvidence(skill, i),
                              maxLine: 3,
                              isRequiredField: true,
                              readOnly: readOnly,
                              fillBgColor: Colors.white.withValues(alpha: 0.65),
                              onChange:
                                  onEvidenceChanged == null
                                      ? null
                                      : (value) => onEvidenceChanged!(i, value),
                            ),
                            if (hrNoteText != null && hrStatusText != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: const Color(
                                  0xFFD1D5DB,
                                ).withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 12),
                              InputTextField(
                                title: 'Ý kiến HR',
                                hintText: '',
                                initialValue: hrNoteText!(i),
                                readOnly: true,
                                enable: false,
                                isRequiredField: false,
                                fillBgColor: Colors.white.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InputTextField(
                                title: 'Trạng thái',
                                hintText: '',
                                initialValue: hrStatusText!(i),
                                readOnly: true,
                                enable: false,
                                isRequiredField: false,
                                fillBgColor: Colors.white.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ],
                            if (i != skills.length - 1) ...[
                              const SizedBox(height: 16),
                              const _DashedDivider(),
                            ],
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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 6.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          children: List.generate(count, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: dashSpace),
              child: Container(
                width: dashWidth,
                height: 0.5,
                color: Colors.grey,
              ),
            );
          }),
        );
      },
    );
  }
}
