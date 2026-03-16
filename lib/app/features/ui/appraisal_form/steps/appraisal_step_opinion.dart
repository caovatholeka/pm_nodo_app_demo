import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

class AppraisalStepOpinion extends StatelessWidget {
  final List<SuggestIdEntity> suggests;
  final List<TextEditingController> controllers;
  final bool isLeaderReview;

  const AppraisalStepOpinion({
    super.key,
    required this.suggests,
    required this.controllers,
    this.isLeaderReview = false,
  });

  Color get _sectionBg => isLeaderReview ? const Color(0xFFE5E0F0) : const Color(0xFFF7FFF6);
  Color get _accent => isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF10B981);
  Color get _titleColor => isLeaderReview ? const Color(0xFF7030A0) : const Color(0xFF0B6F2F);

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'IV. Ý kiến - Đề xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SvgPicture.asset(
                    AppAssets.icQuestion,
                    width: 20,
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
                children: List.generate(suggests.length, (i) {
                  final item = suggests[i];

                  return Padding(
                    padding: EdgeInsets.only(bottom: i == suggests.length - 1 ? 0 : 14),
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
                                  '${item.code ?? ''} - ${item.name ?? ''}',
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
                            hintText: 'Nhập ý kiến / đề xuất...',
                            controller: controllers[i],
                            maxLine: 4,
                            isRequiredField: false,
                            readOnly: true,
                            fillBgColor: const Color(0xFFEFF8EF),
                          ),
                        ],
                      ),
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
