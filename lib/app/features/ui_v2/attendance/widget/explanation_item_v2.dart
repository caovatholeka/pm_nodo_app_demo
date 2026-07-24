import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/utils/date_utils.dart';

/// Bản tối (v2) của [ExplanationItem]
/// (`lib/app/features/widgets/explanation_card.dart`) — 1 thẻ trong danh sách
/// giải trình công. Cùng dữ liệu/callback [onExplain], chỉ đổi màu/nền.
class ExplanationItemV2 extends StatelessWidget {
  final WorkEntryEntity workEntryEntity;
  final VoidCallback? onExplain;

  const ExplanationItemV2({
    super.key,
    required this.workEntryEntity,
    this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return GestureDetector(
      onTap: onExplain,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 100,
              decoration: BoxDecoration(
                color: ((workEntryEntity.state ?? "") == "hr_confirm")
                    ? AppTokensV2.accent
                    : AppTokensV2.warn,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            workEntryEntity.workEntryLabel ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              color: AppTokensV2.fg,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text(
                        "${s.explain_cardCome}:",
                        style: AppTokensV2.caption,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        Utils().floatToTimeString(
                                workEntryEntity.dateStartCommit ?? 0.0) ??
                            "",
                        style: AppTokensV2.caption,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "${s.explain_cardLeave}:",
                        style: AppTokensV2.caption,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        Utils().floatToTimeString(
                                workEntryEntity.dateStopCommit ?? 0.0) ??
                            "",
                        style: AppTokensV2.caption,
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        text: "${s.explain_cardTime}: ",
                        style: AppTokensV2.caption,
                        children: [
                          TextSpan(
                            text: AppDateUtils.changeIso8601StringToDateTimeString(
                                workEntryEntity.date),
                            style: const TextStyle(
                              color: AppTokensV2.fgSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
