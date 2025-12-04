import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/work_entry_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/attendance/attendance_data_tab/explanation_tab/send_invalid_page.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';

import '../../../../../core/commons/app_colors.dart';
import '../../../../widgets/explanation_card.dart';
import '../attendance_tab/attendance_tab.dart';
import 'explanation_cubit.dart';

class ExplanationTab extends StatefulWidget {
  const ExplanationTab({super.key});

  @override
  State<ExplanationTab> createState() => _ExplanationTabState();
}

class _ExplanationTabState extends State<ExplanationTab> {
  final TextEditingController _reasonController = TextEditingController();
  final _cubit = GetIt.I.get<ExplanationCubit>();
  bool _isReasonFilled = false;
  @override
  void initState() {

    _cubit.setYearMonth(DateTime.now().year, DateTime.now().month);
    super.initState();
    _cubit.getListWorkEntries();

    _reasonController.addListener(() {
      final text = _reasonController.text.trim();
      setState(() => _isReasonFilled = text.isNotEmpty);
      _cubit.updateReason(text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future _onRefresh() async {
    _cubit.getListWorkEntries();
  }

  Future<void> _sendInvalid(WorkEntryEntity entity) async{
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendInvalidPage(
        workEntryEntity: entity,
      )),
    );

    if(result != null && result){
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplanationCubit, ExplanationState>(
      bloc: _cubit,
      listener: (context, state) {
        try {
          if (state.submitSuccess == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              try {
                showDialog(
                  context: context,
                  builder: (_) => CustomDialog(
                    iconPath: AppAssets.ic_done,
                    title: "Thành công",
                    content: "Đã gửi giải trình thành công!",
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              } catch (e, st) {
                debugPrint('Error showing dialog: $e\n$st');
              }
              try {
                _reasonController.clear();
              } catch (e, st) {
                debugPrint('Error clearing controller: $e\n$st');
              }
              Future.microtask(() {
                try {
                  _cubit.resetSubmitSuccess();
                } catch (e, st) {
                  debugPrint('Error resetting submitSuccess: $e\n$st');
                }
              });
            });
          }
        } catch (e, st) {
          debugPrint('Listener caught error: $e\n$st');
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child:_workEntriesWidget,
        );


        // if (state.isLoading) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        //
        // final name = state.profile?.name ?? "Không xác định";
        //
        // return SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       _buildReadOnlyField("Nhân viên", name),
        //       const SizedBox(height: 10),
        //       _buildReadOnlyField(
        //         "Phòng ban",
        //         state.profile?.department?.name ?? "Không xác định",
        //       ),
        //       const SizedBox(height: 10),
        //       _buildReadOnlyField("Giờ đến", "08:30"),
        //       const SizedBox(height: 10),
        //       _buildReadOnlyField("Giờ về", "18:00"),
        //       const SizedBox(height: 10),
        //       InputTextField(
        //         title: "Lý do",
        //         hintText: "Nhập lý do",
        //         controller: _reasonController,
        //         isRequiredField: true,
        //         maxLine: 3,
        //         enable: true,
        //         onChange: (value) {
        //           _cubit.updateReason(value.trim());
        //         },
        //       ),
        //       const SizedBox(height: 24),
        //       PrimaryButton(
        //         mainText: "Xác nhận",
        //         enable: _isReasonFilled,
        //         callback: () {
        //           if (_isReasonFilled) {
        //             _cubit.sendInvalidReason();
        //           }
        //         },
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }

  // danh sach giai trinh cong
  get _workEntriesWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYearMonthDropdown(),
        _listWorkEntries,
      ],
    );
  }

  // danh sách giải trình
  get _listWorkEntries {
    return BlocBuilder<ExplanationCubit,ExplanationState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.loadStatus != cur.loadStatus ||
            prev.listWorkEntries != cur.listWorkEntries,
        builder: (context,state){
          return state.loadStatus == LoadStatus.LOADING ? 
              Center(child: CircularProgressIndicator(color: AppColors.themePrimaryDefault,),) 
              : ((state.listWorkEntries ?? []).isNotEmpty ?
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                shrinkWrap: true,
                controller: ScrollController(),
                itemCount: (state.listWorkEntries ?? []).length,
                itemBuilder: (context,index){
                  WorkEntryEntity entity = (state.listWorkEntries ?? [])[index];
                  return ExplanationItem(
                    workEntryEntity: entity,
                    onExplain: () async{
                      await _sendInvalid(entity);
                    },
                  );
                }),
          ):Center(child: Text("Không có dữ liệu")).paddingOnly(top: 30)
          );
          /*
          return ;
          
           */
        });
  }
  // chon time
  Widget _buildYearMonthDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () async{
            final s = _cubit.state;
            await _showYearMonthPicker(
              context: context,
              defaultValue: DateTime(s.selectedYear ?? DateTime.now().year , s.selectedMonth ?? DateTime.now().month , 1),
              onConfirm: (month, year) {
                _cubit.setYearMonth(int.parse(year) , int.parse(month));
                _cubit.getListWorkEntries();
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.themePrimaryDefault,
                borderRadius: BorderRadius.all(Radius.circular(100))
            ),
            child: BlocBuilder<ExplanationCubit,ExplanationState>(
                bloc: _cubit,
                buildWhen: (prev,cur) => prev.selectedMonth != cur.selectedMonth ||
                    prev.selectedYear != cur.selectedYear,
                builder: (context,state){
                  return Text(
                    "Tháng ${state.selectedMonth}, ${state.selectedYear}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                    ),
                  );
                }
            ),

          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: (){
                _shiftMonth(-1);
              },
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.whiteColor
                ),
                child: InkWell(
                  onTap: (){
                    _shiftMonth(-1);
                  },
                  child: Center(child: Icon(Icons.arrow_back_ios,color: AppColors.themePrimaryDefault,size: 16,)),
                ),
              ).paddingOnly(right: 12),
            ),
            InkWell(
              onTap: (){
                _shiftMonth(1);
              },
              child: Container(
                width: 30,
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.whiteColor
                ),
                child: InkWell(
                  onTap: (){
                    _shiftMonth(1);
                  },
                  child: Center(child: Icon(Icons.arrow_forward_ios,color: AppColors.themePrimaryDefault,size: 16,)),
                ).paddingOnly(right: 4),
              ),
            )
          ],
        )
      ],
    );
  }

  Future<void> _showYearMonthPicker({
    required BuildContext context,
    DateTime? defaultValue,
    required void Function(String month, String year) onConfirm,
  }) async {
    final now = DateTime.now();
    final initial = defaultValue ?? DateTime(now.year, now.month, 1);

    DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: LocaleType.vi,
      pickerModel: YearMonthPicker(
        currentTime: initial,
        minTime: DateTime(2015, 1, 1),
        maxTime: DateTime(2035, 12, 31),
        locale: LocaleType.vi,
      ),
      onConfirm: (dt) {
        final y = dt.year.toString();
        final m = dt.month.toString().padLeft(2, '0');
        onConfirm(m, y);
      },
    );
  }

  // on change month
  void _shiftMonth(int delta) {
    final s = _cubit.state;
    int y = s.selectedYear ?? DateTime.now().year ;
    int m = (s.selectedMonth ?? DateTime.now().month) + delta;

    if (m > 12) { m = 1;  y += 1; }
    if (m < 1)  { m = 12; y -= 1; }

    _cubit.setYearMonth(y, m);
    _cubit.getListWorkEntries();
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
