import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

import '../../../../core/commons/app_colors.dart';
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
    this.isLeaderReview = false
  });

  @override
  Widget build(BuildContext context) {
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

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'II. Tinh thần trách nhiệm (20%)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SvgPicture.asset(AppAssets.icQuestion, width: 20),
                ],
              ),
            ),

            /// BODY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
              decoration: BoxDecoration(
                color: isLeaderReview ? Color(0xFFE5E0F0) : Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Row(
                    children:  [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor:isLeaderReview ? Color(0xFF7030A0): Color(0xFF10B981),
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tiêu chí đánh giá Tinh thần trách nhiệm',
                          style: TextStyle(
                            color: isLeaderReview ? Color(0xFF7030A0): Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  isLeaderReview ? Text(
                    'Cấp trên trực tiếp đánh giá (Max = 5 điểm)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.themeDarkDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ):
                  const Text(
                    'Những việc liên quan trực tiếp đến nhóm nhỏ của người được đánh giá, có liên quan đến công việc của người được đánh giá',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// LIST ITEM
                  Column(
                    children: List.generate(responses.length, (i) {

                      final item = responses[i];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// TITLE ITEM
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
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
                                    fontSize: 13,
                                  ),
                                ),

                                TextSpan(
                                  text: ' - ${item.name ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),

                                const TextSpan(
                                  text: ' - Hệ số 2',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Điểm',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// STAR RATING
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 30,
                              children: List.generate(5, (j) {

                                final filled = j < ratings[i];

                                return InkWell(
                                  onTap: () => onRate(i, j + 1),
                                  child: SvgPicture.asset(
                                    AppAssets.icStar,
                                    width: 30,
                                    height: 30,
                                    color: filled
                                        ? const Color(0xFFFFCB45)
                                        : const Color(0xFF64748B),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// EVIDENCE
                          InputTextField(
                            title: 'Ghi rõ những gì được, chưa được',
                            hintText: 'Nhập dẫn chứng...',
                            controller: evidences[i],
                            maxLine: 3,
                            isRequiredField: true,
                          ),

                          /// DIVIDER
                          if (i != responses.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: CustomPaint(
                                size: const Size(double.infinity, 1),
                                painter: DotDividerPainter(color: Color(0xFFD1FAE5)),
                              ),
                            ),
                        ],
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

