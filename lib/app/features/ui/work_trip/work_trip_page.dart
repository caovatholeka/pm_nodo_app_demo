import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/features/ui/work_trip/request_new_trip_page.dart';
import 'package:pm_app/app/features/ui/work_trip/widget/work_trip_list_item.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../widgets/input_text_field.dart';

class WorkTripPage extends StatefulWidget {
  const WorkTripPage({super.key});

  @override
  State<WorkTripPage> createState() => _WorkTripPageState();
}

class _WorkTripPageState extends State<WorkTripPage> {
  final _cubit = GetIt.I<WorkTripCubit>();

  ScrollController controller = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _cubit.getListWorkTrips();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future _onRefresh() async {
    _cubit.getListWorkTrips();
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
    return BlocConsumer<WorkTripCubit,WorkTripState>(
        bloc: _cubit,
        listenWhen: (prev,cur) => prev.loadDataStatus != cur.loadDataStatus,
        listener: (context,state){

        },
        builder: (context,state){
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            appBar: MyAppBar(titleAppbar: "Đơn công tác"),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16,),
                  _filterWidget,
                  const SizedBox(height: 16,),
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
            child: InputTextField(
              title: "",
              hintText: "",
              isRequiredField: false,
              disableTitle: true,
              enable: true,
              readOnly: true,
              controller: _searchController,
              suffixIcon:AppAssets.icCalendar,
              onSuffixAction: (){
                // _cubit.getListTasks();
                logger.d("open calendar");
              },
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
    return BlocConsumer<WorkTripCubit,WorkTripState>(
      bloc: _cubit,
      listener: (prev,cur){

      },
      builder: (context,state) {
        return RefreshIndicator(
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
                  // _openDetail(entity);
                },
              ).paddingOnly(bottom: 12);
            },
          ),
        );
      }
    );
  }
}
