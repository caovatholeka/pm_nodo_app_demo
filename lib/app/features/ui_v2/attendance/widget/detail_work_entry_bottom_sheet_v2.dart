import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/data/models/entities/work_entity.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/utils/date_utils.dart';

/// Bản tối (v2) của [DetailWorkEntryBottomSheet]
/// (`lib/app/features/ui/attendance/bottom_sheet/detail_work_entry_bottom_sheet.dart`).
/// Cùng tham số [workEntity]/[date], cùng bố cục các trường chỉ đọc — chỉ đổi
/// màu nền/chữ sang tối. Các trường dùng lại [InputTextField] gốc (đã hỗ trợ
/// `fillBgColor`/`style` tuỳ biến) để không phải nhân bản logic input.
class DetailWorkEntryBottomSheetV2 extends StatefulWidget {
  final WorkEntity? workEntity;
  final String? date;

  const DetailWorkEntryBottomSheetV2({
    super.key,
    this.workEntity,
    this.date,
  });

  @override
  State<DetailWorkEntryBottomSheetV2> createState() =>
      _DetailWorkEntryBottomSheetV2State();
}

class _DetailWorkEntryBottomSheetV2State
    extends State<DetailWorkEntryBottomSheetV2> {
  String toHHmm(String input) {
    try {
      final dt = DateTime.parse(input.replaceFirst(' ', 'T'));
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "";
    }
  }

  static TextStyle get _fieldStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppTokensV2.fg,
  );

  Widget _field({
    required String title,
    required String value,
  }) {
    return InputTextField(
      v2Style: true,
      title: title,
      hintText: "",
      isRequiredField: false,
      enable: true,
      readOnly: true,
      fillBgColor: AppTokensV2.surfaceStrong,
      style: _fieldStyle,
      controller: TextEditingController(text: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      height: ScreenSize.of(context).height * 0.9,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        color: AppTokensV2.bgTop,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Co lại (…) khi thiếu chỗ — cỡ chữ hệ thống lớn từng làm dòng này tràn.
                    Flexible(
                      child: Text(
                        s.work_data_dtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTokensV2.fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateUtils.changeIso8601StringToDateTimeString(
                          widget.date ?? ""),
                      style: AppTokensV2.caption,
                    )
                  ],
                ).paddingOnly(bottom: 16),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: AppTokensV2.border,
              ).paddingOnly(bottom: 16),
              SizedBox(
                height: ScreenSize.of(context).height * 0.75,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(
                        title: s.work_data_dName,
                        value: widget.workEntity?.workEntryLabel ?? "",
                      ).paddingOnly(bottom: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dcheckIn,
                              value: AppDateUtils().formatTimeAmPm(
                                  widget.workEntity?.dateStart ?? ""),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dcheckOut,
                              value: AppDateUtils().formatTimeAmPm(
                                  widget.workEntity?.dateStop ?? ""),
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: AppTokensV2.border,
                      ).paddingOnly(bottom: 12),
                      _field(
                        title: s.work_data_dShift,
                        value: widget.workEntity?.shift?.name ?? "",
                      ).paddingOnly(bottom: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dLate,
                              value: widget.workEntity?.lateTime ?? "",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dSoon,
                              value: widget.workEntity?.earlyTime ?? "",
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dTimeWork,
                              value: widget.workEntity?.workTime ?? "",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: _field(
                              title: s.work_data_dInvalidTime,
                              value: widget.workEntity?.totalInvalidTime ?? "",
                            ),
                          )
                        ],
                      ).paddingOnly(bottom: 12),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: AppTokensV2.border,
                      ).paddingOnly(bottom: 12),
                      _field(
                        title: s.work_data_dBreakTime,
                        value: "0.0",
                      ).paddingOnly(bottom: 16),
                      PrimaryButtonV2(
                        label: s.day_off_donebtn,
                        onTap: () {
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
