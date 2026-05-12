import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/appraisal_help_tooltip.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

class AppraisalStepOpinion extends StatelessWidget {
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

  const AppraisalStepOpinion({
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

  Color get _sectionBg =>
      isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6);
  Color get _accent =>
      isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF10B981);
  Color get _titleColor =>
      isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF0B6F2F);

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

  String _itemTitle(SuggestIdEntity item) {
    final code = item.code?.trim().toUpperCase();
    if (isHrReview && code == 'DG03') {
      return 'DG03 - Ý kiến của HR';
    }
    if (isLeaderReview && code == 'DG02') {
      return 'DG02 - Cấp trên đánh giá';
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EEF8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.appraisal_step_opinion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  AppraisalHelpTooltip(
                    message: 'Nhập ý kiến của bạn',
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: _sectionBg,
                borderRadius: const BorderRadius.only(
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
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
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
                                  _itemTitle(item),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _titleColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          InputTextField(
                            title: '',
                            hintText: s.appraisal_suggestion_hint,
                            controller: controller,
                            maxLine: 4,
                            isRequiredField: false,
                            readOnly: readOnly,
                            fillBgColor: const Color(0xFFEFF8EF),
                            onChange: (value) {
                              item.note = value;
                              onNoteChanged?.call(itemIndex, value);
                            },
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
                              initialValue: hrNoteText!(itemIndex),
                              readOnly: true,
                              enable: false,
                              isRequiredField: false,
                              fillBgColor: Colors.white.withValues(alpha: 0.55),
                            ),
                            const SizedBox(height: 12),
                            InputTextField(
                              title: 'Trạng thái',
                              hintText: '',
                              initialValue: hrStatusText!(itemIndex),
                              readOnly: true,
                              enable: false,
                              isRequiredField: false,
                              fillBgColor: Colors.white.withValues(alpha: 0.55),
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
