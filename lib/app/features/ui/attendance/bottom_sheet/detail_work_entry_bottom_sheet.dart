import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

import '../../../../core/utils/date_utils.dart';

class DetailWorkEntryBottomSheet extends StatefulWidget {
  final WorkEntity? workEntity;
  final String? date;

  const DetailWorkEntryBottomSheet({
    super.key,
    this.workEntity,
    this.date,
  });


  @override
  State<DetailWorkEntryBottomSheet> createState() => _DetailWorkEntryBottomSheetState();
}

class _DetailWorkEntryBottomSheetState extends State<DetailWorkEntryBottomSheet> {

  String toHHmm(String input) {
    try {
      final dt = DateTime.parse(input.replaceFirst(' ', 'T'));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "";
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenSize.of(context).height*0.9,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16)
        ),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12,top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dữ liệu chấm công",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.themeBlackDefault
                      ),
                    ),
                    Text(AppDateUtils.changeIso8601StringToDateTimeString(widget.date ?? ""),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGray600
                      ),
                    )
                  ],
                ).paddingOnly(bottom: 16),
              ),
              Container(height: 1, width: double.infinity,
                color: AppColors.lineGray50,
              ).paddingOnly(bottom: 16),

              SizedBox(
                height: ScreenSize.of(context).height*0.75,
                child: SingleChildScrollView(padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InputTextField(
                          title: "Tên",
                          hintText: "",
                          isRequiredField: false,
                          enable: true,
                          readOnly: true,
                          controller: TextEditingController(text: widget.workEntity?.workEntryLabel ?? ""),
                      ).paddingOnly(bottom: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Check In",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: toHHmm(widget.workEntity?.dateStart ?? "")),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Check Out",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: toHHmm(widget.workEntity?.dateStop ?? "")),
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),

                      Container(width: double.infinity,height: 1,
                        color: AppColors.lineGray50
                      ).paddingOnly(bottom: 12),

                      InputTextField(
                        title: "Ca làm việc",
                        hintText: "",
                        isRequiredField: false,
                        enable: true,
                        readOnly: true,
                        controller: TextEditingController(text: widget.workEntity?.shift?.name ?? ""),
                      ).paddingOnly(bottom: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Giờ đến trễ",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: widget.workEntity?.lateTime ?? ""),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Thời gian đến sớm",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: widget.workEntity?.earlyTime ?? ""),
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Thời gian làm việc",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: widget.workEntity?.workTime ?? ""),
                            ),
                          ),
                          const SizedBox(width: 12,),
                          Expanded(
                            flex: 1,
                            child: InputTextField(
                              title: "Thời gian không hợp lệ",
                              hintText: "",
                              isRequiredField: false,
                              enable: true,
                              readOnly: true,
                              controller: TextEditingController(text: widget.workEntity?.totalInvalidTime ?? ""),
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),

                      Container(width: double.infinity,height: 1,
                          color: AppColors.lineGray50
                      ).paddingOnly(bottom: 12),

                      InputTextField(
                        title: "Thời gian nghỉ",
                        hintText: "",
                        isRequiredField: false,
                        enable: true,
                        readOnly: true,
                        controller: TextEditingController(text: "0.0"),
                      ).paddingOnly(bottom: 16),

                      PrimaryButton(mainText: "Xong",
                        callback: (){
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
