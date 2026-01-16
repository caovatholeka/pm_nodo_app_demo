import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/app_shadow.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../core/utils/date_utils.dart';

class ExplanationItem extends StatelessWidget {
  final WorkEntryEntity workEntryEntity;
  final VoidCallback? onExplain;


  const ExplanationItem({
    super.key,
    required this.workEntryEntity,
    this.onExplain
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return GestureDetector(
      onTap: onExplain,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadow.bottomShadow
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 100,
              decoration: BoxDecoration(
                // workEntryEntity.note.toString().isNotEmpty
                 color: ((workEntryEntity.state ?? "") == "hr_confirm"
                    )  ?
                 AppColors.themePrimaryDefault:
                 Colors.orangeAccent,
                borderRadius: BorderRadius.only(
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
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(children: [
                      Text("${s.explain_cardCome}:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGray600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text(Utils().floatToTimeString(workEntryEntity.dateStartCommit ?? 0.0) ?? "",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGray600
                        ),
                      ),
                      const SizedBox(width: 16,),
                      Text("${s.explain_cardLeave}:",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGray600
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Text(Utils().floatToTimeString(workEntryEntity.dateStopCommit ?? 0.0) ?? "" ,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGray600
                        ),
                      ),
                    ],),
                    const SizedBox(height: 6),

                    Text.rich(
                      TextSpan(
                        text: "${s.explain_cardTime}: ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13.5,
                        ),
                       
                        children: [
                          TextSpan(
                            text:AppDateUtils.changeIso8601StringToDateTimeString(workEntryEntity.date) ,
                            style: const TextStyle(
                              color: Colors.black87,
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
