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
          border: Border.all(color: const Color(0xFFE6EEF8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    'IV. Ý kiến - Đề xuất',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF7FFF6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: List.generate(suggests.length, (i) {

                  final item = suggests[i];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isLeaderReview ? Color(0xFF7030A0) : Color(0xFF0B6F2F),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              '${item.code ?? ''} - ${item.name ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isLeaderReview ? Color(0xFFE5E0F0) : Color(0xFF0B6F2F),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      InputTextField(
                        title: '',
                        hintText: 'Nhập ý kiến / đề xuất...',
                        controller: controllers[i],
                        maxLine: 4,
                        isRequiredField: false,
                        fillBgColor: Colors.transparent,
                      ),

                      const SizedBox(height: 16),
                    ],
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