import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/features/ui/work_trip/request_new_trip_page.dart';
import 'package:pm_app/app/features/ui/work_trip/widget/work_trip_list_item.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_detail_page.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/custom_calendar_range_sheet.dart';
import '../../widgets/input_text_field.dart';

class WorkTripPage extends StatefulWidget {
  final bool? isFromHome;
  const WorkTripPage({super.key, this.isFromHome});

  @override
  State<WorkTripPage> createState() => _WorkTripPageState();
}

class _WorkTripPageState extends State<WorkTripPage> {
  final _cubit = GetIt.I<WorkTripCubit>();

  ScrollController controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    final delta = x.weekday - 1;
    return x.subtract(Duration(days: delta));
  }

  static DateTimeRange _weekOf(DateTime d) {
    final start = _mondayOf(d);
    final end = start.add(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange selectedWeek = _weekOf(DateTime.now());
  final _df = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    _cubit.getListWorkTrips();
    super.initState();
  }

  @override
  void dispose() {
    _cubit.onResetStatus();
    super.dispose();
  }

  void dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future _onRefresh() async {
    _cubit.getListWorkTrips();
  }

  Future _openDetail(WorkTripEntity entity) async{
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkTripDetailPage(
        workEntity: entity,
        workId: entity.id,
      )),
    );

    if(result != null && result){
      _onRefresh();
    }
  }

  Future requestNewTrip() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestNewTripPage()),
    );

    if(result != null && result){
      _onRefresh();
    }

  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<WorkTripCubit,WorkTripState>(
        bloc: _cubit,
        listenWhen: (prev,cur) => prev.loadDataStatus != cur.loadDataStatus,
        listener: (context,state){

        },
        builder: (context,state){
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            appBar: MyAppBar(titleAppbar: s.bt_title,
              haveBackButton: widget.isFromHome ?? false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16,),
                  _filterWidget,
                  // const SizedBox(height: 16,),
                  _listWidget,
                  const SizedBox(height: 32,),
                ],
              ),
            ),
          );
        });
  }

  get _filterWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 8,
            child: BlocBuilder<WorkTripCubit,WorkTripState>(
              bloc: _cubit,
              buildWhen:  (prev, cur) =>
                  prev.startDateFilter != cur.startDateFilter ||
                  prev.endDateFilter != cur.endDateFilter,
              builder: (context,state) {
                String week = "";
                if ((state.startDateFilter ?? "").isNotEmpty) {
                  week = "${state.startDateFilter} - ${state.endDateFilter}";
                }
                return InputTextField(
                  title: "",
                  hintText: "",
                  isRequiredField: false,
                  disableTitle: true,
                  enable: true,
                  readOnly: true,
                  controller: _searchController..text = week,
                  suffixIcon:AppAssets.icCalendar,
                  callback: () async{
                    final res = await showModalBottomSheet<DateTimeRange?>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      backgroundColor: Colors.white,
                      builder:
                          (_) => CalendarRangeSheet(
                        initial: selectedWeek,
                        locale: "en",
                      ),
                    );

                    if (res == null) {
                      _searchController.clear();
                      _cubit.onChangeDateFilter("", "");
                      _cubit.getListWorkTrips();
                      return;
                    }

                    selectedWeek = res;
                    String start = _df.format(selectedWeek.start);
                    String end = _df.format(selectedWeek.end);

                    _cubit.onChangeDateFilter(start, end);
                    _cubit.getListWorkTrips();
                  },
                );
              }
            )
        ),
        const SizedBox(width: 8,),
        Expanded(
            flex: 1,
            child: InkWell(
              onTap: (){
                requestNewTrip();
              },
              child: Container(
                height: 44,
                width: 46,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: AppColors.mainPrimaryColor6
                ),
                child: Center(child: Icon(Icons.add,color: AppColors.whiteColor,)),
              ),
            )
        ),
      ],
    );
  }

  get _listWidget {
    final s = S.of(context);
    return BlocConsumer<WorkTripCubit,WorkTripState>(
      bloc: _cubit,
      listener: (prev,cur){

      },
      builder: (context,state) {
        if (state.loadDataStatus == LoadStatus.LOADING) {
          return Center(child: CircularProgressIndicator(color: AppColors.themePrimaryDefault,));
        }
        else {
          return (state.listWorkTrips ?? []).isEmpty ?
          Center(child: Text(s.bt_empty).paddingOnly(top: 100)):
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20),
              shrinkWrap: true,
              controller: controller,
              itemCount: (state.listWorkTrips ?? []).length,
              itemBuilder: (context, index) {
                WorkTripEntity entity = (state.listWorkTrips ?? [])[index];
                return WorkTripListItem(
                  entity: entity,
                  onShowDetail: () {
                    _openDetail(entity);
                  },
                ).paddingOnly(bottom: 12);
              },
            ),
          );
        }
      }
    );
  }
}
