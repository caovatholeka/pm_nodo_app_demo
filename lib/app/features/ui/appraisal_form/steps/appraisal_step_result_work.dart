import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

class AppraisalStepResultWork extends StatelessWidget {
  final List<int> ratings;
  final void Function(int index, int value) onRate;

  final TextEditingController jobCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController evidenceCtrl;

  final bool readOnly;

  const AppraisalStepResultWork({
    super.key,
    required this.ratings,
    required this.onRate,
    required this.jobCtrl,
    required this.weightCtrl,
    required this.evidenceCtrl,
    this.readOnly = false,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'I. Kết quả công việc (70%)',
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

            /// NOTE
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF7FFF6),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xFF10B981),
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Các việc đã làm',
                        style: TextStyle(
                          color: Color(0xFF065F46),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Lưu ý: Đọc kỹ sử dụng trước khi dùng. Đánh giá theo thang điểm 1–5.(Dựa theo hướng dẫn cho sẵn)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF7FFF6),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// JOB
                  InputTextField(
                    title: 'Công việc đã làm',
                    hintText: 'Nhập công việc đã làm',
                    controller: jobCtrl,
                    readOnly: readOnly,
                    isRequiredField: true,
                  ),

                  const SizedBox(height: 12),

                  /// WEIGHT
                  InputTextField(
                    title: 'Tỷ trọng %',
                    hintText: 'Nhập % (0–100)',
                    controller: weightCtrl,
                    readOnly: readOnly,
                    isRequiredField: true,
                  ),

                  const SizedBox(height: 16),

                  /// RATINGS
                  _rating('1. Khối lượng', 0),
                  _rating('2. Chất lượng', 1),
                  _rating('3. Tiến độ', 2),

                  const SizedBox(height: 12),

                  /// EVIDENCE
                  InputTextField(
                    title: 'Dẫn chứng',
                    hintText: 'Nhập dẫn chứng...',
                    controller: evidenceCtrl,
                    readOnly: readOnly,
                    isRequiredField: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rating(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 35,
            children: List.generate(5, (i) {

              final filled = i < ratings[index];

              return InkWell(
                onTap: readOnly
                    ? null
                    : () => onRate(index, i + 1),
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

        const SizedBox(height: 16),
      ],
    );
  }
}