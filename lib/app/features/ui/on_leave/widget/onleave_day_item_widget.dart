// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/utils/date_utils.dart';
// import '../../../widgets/input_text_field.dart';
//
// class OnleaveDayItemWidget extends StatefulWidget {
//   String date;
//
//   OnleaveDayItemWidget({required this.date});
//
//   @override
//   State<OnleaveDayItemWidget> createState() => _OnleaveDayItemWidgetState();
// }
//
// class _OnleaveDayItemWidgetState extends State<OnleaveDayItemWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//             flex: 1,
//             child: InputTextField(
//               title: "Ngày",
//               hintText: "",
//               isRequiredField: true,
//               readOnly: true,
//               controller: TextEditingController(text: AppDateUtils.changeIso8601StringToDateTimeString(widget.date)),
//             )),
//         const SizedBox(width: 10,),
//         Expanded(
//             flex: 1,
//             child: BlocBuilder<CreateOnLeaveCubit,CreateOnLeaveState>(
//                 buildWhen: (prev,cur) => prev.leaveType != cur.leaveType ||
//                     prev.currentLeaveType != cur.currentLeaveType,
//                 builder: (context,state){
//                   return InputTextField(
//                     title: "Loại nghỉ",
//                     hintText: "",
//                     isRequiredField: true,
//                     controller: typeController,
//                     enable: true, z
//                     readOnly: true,
//                     suffixIcon: AppAssets.icArrowDown,
//                     callback: (){
//                       _openTypeLeaveBottomSheet(state.listTypeLeaves ?? []);
//                     },
//                     // validator: (value) =>
//                     //     Validator.validateEmpty(value, "Loại nghỉ"),
//                   );
//                 }))
//       ],
//     ).paddingOnly(bottom: 16);
//   }
// }
