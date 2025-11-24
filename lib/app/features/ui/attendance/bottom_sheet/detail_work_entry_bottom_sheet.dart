import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class DetailWorkEntryBottomSheet extends StatefulWidget {
  final WorkEntity? workEntity;
  final String? date;

  DetailWorkEntryBottomSheet({
    Key? key,
    this.workEntity,
    this.date,
  }): super(key: key);


  @override
  State<DetailWorkEntryBottomSheet> createState() => _DetailWorkEntryBottomSheetState();
}

class _DetailWorkEntryBottomSheetState extends State<DetailWorkEntryBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenSize.of(context).height*0.9,
      color: Colors.transparent,
      child: Padding(padding: const EdgeInsets.only(left: 16,right: 16,bottom: 100),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                        Text(widget.date ?? "",
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

                  Padding(padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Column(
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
                                controller: TextEditingController(text: "${widget.workEntity?.dateStart ?? 0.0}"),
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
                                controller: TextEditingController(text: "${widget.workEntity?.dateStop ?? 0.0}"),
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
                                controller: TextEditingController(text: "${widget.workEntity?.lateTime ?? 0.0}"),
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
                                controller: TextEditingController(text: "${widget.workEntity?.earlyTime ?? 0.0}"),
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
                                controller: TextEditingController(text: "${widget.workEntity?.workTime ?? 0.0}"),
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
                                controller: TextEditingController(text: "${widget.workEntity?.totalInvalidTime ?? 0.0}"),
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),

    );
  }
}
