import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../widgets/appraisal_help_tooltip_v2.dart';

/// Bản tối (v2) của [AppraisalStepOpinion]
/// (`lib/app/features/ui/appraisal_form/steps/appraisal_step_opinion.dart`).
/// Cùng constructor/callback, cùng logic lọc mục hiển thị theo
/// `isHrReview`/`isLeaderReview` — chỉ đổi màu sang tông tối.
class AppraisalStepOpinionV2 extends StatelessWidget {
  final List<SuggestIdEntity> suggests;
  final List<TextEditingController> controllers;
  final bool isLeaderReview;
  final bool isHrReview;
  final String? evaluationState;
  final bool readOnly;
  final void Function(int index, String value)? onNoteChanged;
  final Future<void> Function(int index)? onItemTap;
  final String Function(int index)? hrNoteText;
  final String Function(int index)? hrStatusText;
  final bool autoShowHelp;

  const AppraisalStepOpinionV2({
    super.key,
    required this.suggests,
    required this.controllers,
    this.isLeaderReview = false,
    this.isHrReview = false,
    this.evaluationState,
    this.readOnly = false,
    this.onNoteChanged,
    this.onItemTap,
    this.hrNoteText,
    this.hrStatusText,
    this.autoShowHelp = false,
  });

  Color get _accent =>
      isLeaderReview ? AppTokensV2.accent2 : AppTokensV2.success;

  List<int> _visibleIndexes() {
    final filtered = <int>[];

    for (int index = 0; index < suggests.length; index++) {
      final code = suggests[index].code?.trim().toUpperCase();
      if (isHrReview) {
        if (code == 'DG03') {
          filtered.add(index);
        }
        continue;
      }

      if (isLeaderReview) {
        if (code == 'DG02') {
          filtered.add(index);
        }
        continue;
      }

      if (code != 'DG02' && code != 'DG03') {
        filtered.add(index);
      }
    }

    if (filtered.isNotEmpty) {
      return filtered;
    }

    return List<int>.generate(suggests.length, (index) => index);
  }

  String _itemTitle(S s, SuggestIdEntity item) {
    final code = item.code?.trim().toUpperCase();
    if (isHrReview && code == 'DG03') {
      return s.v2_appraisal_opinion_dg03_title;
    }
    if (isLeaderReview && code == 'DG02') {
      return s.v2_appraisal_opinion_dg02_title;
    }
    return '${item.code ?? ''} - ${item.name ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final visibleIndexes = _visibleIndexes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.appraisal_step_opinion, style: AppTokensV2.body),
                  AppraisalHelpTooltipV2(
                    message: s.appraisal_suggestion_hint,
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: AppTokensV2.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: List.generate(visibleIndexes.length, (i) {
                  final itemIndex = visibleIndexes[i];
                  final item = suggests[itemIndex];
                  final controller = controllers[itemIndex];

                  final itemContent = Padding(
                    padding: EdgeInsets.only(
                      bottom: i == visibleIndexes.length - 1 ? 0 : 14,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTokensV2.surfaceStrong,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTokensV2.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _accent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _itemTitle(s, item),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            v2Style: true,
                            title: '',
                            hintText: s.appraisal_suggestion_hint,
                            controller: controller,
                            maxLine: 4,
                            maxLength: InputLimits.appraisalNote,
                            buildCounter: inputCounterV2(always: false),
                            isRequiredField: false,
                            readOnly: readOnly,
                            fillBgColor: AppTokensV2.surface,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppTokensV2.fg,
                            ),
                            onChange: (value) {
                              item.note = value;
                              onNoteChanged?.call(itemIndex, value);
                            },
                          ),
                          if (hrNoteText != null && hrStatusText != null) ...[
                            const SizedBox(height: 12),
                            Container(height: 1, color: AppTokensV2.border),
                            const SizedBox(height: 12),
                            InputTextField(
                              v2Style: true,
                              title: s.v2_appraisal_hr_opinion,
                              hintText: '',
                              initialValue: hrNoteText!(itemIndex),
                              readOnly: true,
                              enable: false,
                              isRequiredField: false,
                              fillBgColor: AppTokensV2.surface,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTokensV2.fg,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              v2Style: true,
                              title: s.employee_advanced_status,
                              hintText: '',
                              initialValue: hrStatusText!(itemIndex),
                              readOnly: true,
                              enable: false,
                              isRequiredField: false,
                              fillBgColor: AppTokensV2.surface,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTokensV2.fg,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );

                  if (onItemTap == null) {
                    return itemContent;
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onItemTap!(itemIndex),
                      child: IgnorePointer(ignoring: true, child: itemContent),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
