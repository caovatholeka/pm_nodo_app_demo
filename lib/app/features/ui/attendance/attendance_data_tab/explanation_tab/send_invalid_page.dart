import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/explanation_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../../../../../core/commons/app_assets.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../data/models/entities/work_entry_entity.dart';
import '../../../../widgets/development_alert_dialog.dart';

class SendInvalidPage extends StatefulWidget {
  WorkEntryEntity? workEntryEntity;

  SendInvalidPage({super.key, this.workEntryEntity});

  @override
  State<SendInvalidPage> createState() => _SendInvalidPageState();
}

class _SendInvalidPageState extends State<SendInvalidPage> {
  final _cubit = GetIt.I.get<ExplanationCubit>();
  final TextEditingController controller = TextEditingController();

  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
//(widget.workEntryEntity?.note.toString() ?? "").isNotEmpty
    if((widget.workEntryEntity?.state ?? "") == "hr_confirm") {
      _cubit.onChangeReason(widget.workEntryEntity?.note.toString() ?? "");
    }else{
      _cubit.onChangeReason("");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplanationCubit,ExplanationState>(
        bloc: _cubit,
        listenWhen: (prev,cur) => prev.sendInvalidStatus != cur.sendInvalidStatus,
      listener: (context,state){
        if(state.sendInvalidStatus == LoadStatus.LOADING){
          LoadingOverlay.show(context);
        }else if(state.sendInvalidStatus == LoadStatus.SUCCESS){
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(title: "Thông báo",message: "Đơn giải trình của bạn đã được gửi đi thành công!!");
          Navigator.pop(context,true);
        }else{
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
        }
      },
      builder: (context,state) {
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
              appBar: MyAppBar(
                titleAppbar: "Giải trình công",
                haveBackButton: true,
                haveActionButton: true,
                iconPathAsset: AppAssets.ic_bell,
                actionCallBack: () => DevelopmentAlertDialog.show(context),
              ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12,),
                        InputTextField(
                            title: "Nhân viên",
                            hintText: "",
                            isRequiredField: false,
                          readOnly: true,
                          enable: false,
                          controller: TextEditingController(text:
                           "${GlobalData.instance.userProfile?.name ?? ""} (NV"
                               "${GlobalData.instance.userProfile?.employeeCode ?? ""})" ),
                        ),
                        const SizedBox(height: 12,),
                        InputTextField(
                          title: "Phòng ban",
                          hintText: "",
                          isRequiredField: false,
                          readOnly: true,
                          enable: false,
                          controller: TextEditingController(text:
                            GlobalData.instance.userProfile?.department?.name ?? ""),
                        ),

                        const SizedBox(height: 12,),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: InputTextField(
                                  title: "Giờ đến",
                                  hintText: "",
                                  isRequiredField: false,
                                  enable: true,
                                  inputType: TextInputType.number,
                                  controller: startTimeController,
                                  // controller: TextEditingController(text:
                                  //   Utils().toHhMm(widget.workEntryEntity?.dateStart ?? "")),
                                ),),
                            const SizedBox(width: 12,),
                            Expanded(
                              flex: 1,
                              child: InputTextField(
                                title: "Giờ về",
                                hintText: "",
                                isRequiredField: false,
                                enable: true,
                                controller: endTimeController,
                                // controller: TextEditingController(text:
                                // Utils().toHhMm(widget.workEntryEntity?.dateStop ?? "")),
                              ),),
                          ],
                        ),
                        const SizedBox(height: 12,),
                        InputTextField(
                          title: "Thời gian",
                          hintText: "",
                          isRequiredField: false,
                          readOnly: true,
                          enable: false,
                          controller: TextEditingController(text:
                           AppDateUtils.changeIso8601StringToDateTimeString(widget.workEntryEntity?.date ?? "") ),
                        ),
                        const SizedBox(height: 16,),
                        InputTextField(
                          title: "Lý do",
                          hintText: "",
                          isRequiredField: true,
                          enable:  true,
                          controller: controller..text = state.reason ?? "",
                          maxLine: 5,
                          onChange: (value) {
                           _cubit.onChangeReason(value);
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomSheet: _bottomSheet,
          );
      });
  }

  get _bottomSheet {
    return BlocBuilder<ExplanationCubit,ExplanationState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.reason != cur.reason,
        builder: (context,state){
          bool isEnable = true;
          if((state.reason ?? "").isEmpty ||
            widget.workEntryEntity?.state == "hr_confirm"){
            isEnable = false;
          }
          return InkWell(
            onTap:isEnable ? (){
              _cubit.sendInvalidReason(widget.workEntryEntity?.date ?? "" , 
                double.tryParse(startTimeController.text),
                double.tryParse(endTimeController.text)
              );
            } : (){},
            child: Container(
              margin: const EdgeInsets.only(left: 16,right: 16,bottom: 24),
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: isEnable ?
                  AppColors.themePrimaryDefault 
                  : Color(0xFFDFDFDF),
                borderRadius: BorderRadius.all(Radius.circular(6))
              ),
              child: Center(
                child: Text("Xác nhận",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:isEnable ?
                        AppColors.whiteColor : AppColors.textGray600
                  ),
                ),
              ),
            ),
          );
        });

  }
}
