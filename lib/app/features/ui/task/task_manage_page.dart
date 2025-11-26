
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/screen_size.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui/task/bottomsheet/task_stage_bottom_sheet.dart';
import 'package:pm_app/app/features/ui/task/create_new_task.dart';
import 'package:pm_app/app/features/ui/task/task_detail_page.dart';
import 'package:pm_app/app/features/ui/task/widget/list_task_item.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../bloc/app_cubit.dart';
import '../../widgets/input_text_field.dart';

class TaskManagePage extends StatefulWidget {
  const TaskManagePage({super.key});

  @override
  State<TaskManagePage> createState() => _TaskManagePageState();
}

class _TaskManagePageState extends State<TaskManagePage> {

  final _cubit = GetIt.I.get<TaskCubit>();
  final _appCubit = GetIt.I<AppCubit>();

  ScrollController controller = ScrollController();
  TextEditingController _searchController = TextEditingController();

  // late final List<TaskStageEntity> _tabs;
  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initData() async {
     // _tabs = _appCubit.state.listTaskStages ?? [];
     await _cubit.getListStages();
     // _cubit.onChangeCurrentTabItem(_tabs.first);
    // _cubit.getListTasks();
  }

  Future _onRefresh() async {
    _cubit.getListTasks();
  }

  Future<void> _createNewTask() async{
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNewTask()),
    );

    if(result != null && result){
      _onRefresh();
    }
  }

  Future<void> _openDetailTask(TaskEntity entity) async{
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(
        taskEntity: entity,
        taskId: entity.id,
      )),
    );

    if(result != null && result){
      _onRefresh();
    }
  }

  void _updateTaskStatus(TaskEntity entity) async{
    final picked = await showModalBottomSheet<TaskStageEntity>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskStageBottomSheet(
        listStages: _cubit.state.listTaskStages,
        currentTaskStatus: entity.stage?.code ?? "",
      ),
    );

    if (picked != null) {
      // update
      _cubit.updateTaskStage((entity.id ?? 0).toString(), picked.id ?? 0);
    }
  }

  void dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit,TaskState>(
        bloc: _cubit,
        listenWhen: (prev,cur) => prev.loadStatus != cur.loadStatus,
        listener: (context,state){
          if(state.updateStageStatus == LoadStatus.LOADING ||
            state.getStageStatus == LoadStatus.LOADING){
            LoadingOverlay.show(context);
          }
          else if(state.getStageStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
            // _tabs = List.from(state.listTaskStages ?? []);
          }
          if(state.updateStageStatus == LoadStatus.SUCCESS){
            LoadingOverlay.hide(context);
          }
          else{
            LoadingOverlay.hide(context);
          }
        },
        builder: (context,state){
          return Scaffold(
            backgroundColor: AppColors.bodyColor,
            appBar: AppBar(
              title: Text("Việc cần làm"),
              flexibleSpace: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.appbarBg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: Image.asset(
                  AppAssets.ic_arrowB,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _filterWidget,
                  _tabWidget,
                  Flexible(
                    // width: double.infinity,
                    child:_listTasksWidget
                  ),
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
          child: BlocBuilder<TaskCubit,TaskState>(
              bloc: _cubit,
              buildWhen: (prev,cur) => prev.query != cur.query,
              builder: (context, state){
                return InputTextField(
                  title: "",
                  hintText: "Tìm kiếm công việc",
                  isRequiredField: false,
                  disableTitle: true,
                  enable: true,
                  controller: _searchController..text = state.query ?? "",
                  onChange: (val){
                    _cubit.onChangeQuery(val);
                  },
                  suffixIcon: (state.query ?? "").isNotEmpty ?  AppAssets.icClose : null,
                  onSuffixAction: (){
                    _cubit.onChangeQuery("");
                    _cubit.getListTasks();
                  },
                  prefixWidget: InkWell(
                    onTap: (){
                      dismissKeyboard();
                      _cubit.getListTasks();
                    },
                    child:  SvgPicture.asset(AppAssets.icSearch,width: 18,),
                  ),

                );
              })

        ),
        const SizedBox(width: 8,),
        Expanded(
            flex: 1,
            child: InkWell(
              onTap: (){
                _createNewTask();
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

  get _tabWidget {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocBuilder<TaskCubit,TaskState>(
          bloc: _cubit,
          buildWhen: (prev,cur) => prev.loadStatus != cur.loadStatus ||
              prev.currentTabIndex != cur.currentTabIndex ||
              prev.listTaskStages != cur.listTaskStages,
          builder: (context,state){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    // padding: const EdgeInsets.only(left: 10, right: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: (state.listTaskStages ?? []).length,
                    itemBuilder: (buildContext, index) {
                      TaskStageEntity item = (state.listTaskStages ?? [])[index];
                      return InkWell(
                        onTap: (){
                          // on change tabs
                          if (index != _cubit.state.currentTabIndex) {
                            _cubit.onChangeTab(index);
                            _cubit.onChangeCurrentTabItem(item);
                            _cubit.getListTasks();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: (index == state.currentTabIndex) ? AppColors.themePrimaryDefault :
                                  AppColors.whiteColor,
                            borderRadius: BorderRadius.all(Radius.circular(1000)),
                            border: Border.all(
                                color: Color(0xFFD6E8Ff),
                                width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              item.name ?? "",
                              style: (index == state.currentTabIndex) ?
                              TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
                              ) :
                              TextStyle(
                                  color: AppColors.neutral600,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },

                    separatorBuilder: (buildContext, index) {
                      return const SizedBox(width: 4);
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }

  get _listTasksWidget {
    return BlocBuilder<TaskCubit,TaskState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.loadStatus != cur.loadStatus ||
          prev.listTasks != cur.listTasks,
        builder: (context,state){
          return state.loadStatus == LoadStatus.LOADING ?
             const Center(child: CircularProgressIndicator(color: AppColors.themePrimaryDefault,),) :

          ((state.listTasks ??[]).isNotEmpty ?
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                shrinkWrap: true,
                controller: controller,
                itemCount: (state.listTasks ?? []).length,
                itemBuilder: (context,index){
                  TaskEntity entity = (state.listTasks ?? [])[index];
                  return ListTaskItem(entity: entity,
                    onShowDetail: (){
                      _openDetailTask(entity);
                    },
                    onShowChangeStatus: (){
                      _updateTaskStatus(entity);
                    },
                  ).paddingOnly(bottom: 30);
                }),
            ) : Center(child: Text("Không có dữ liệu"),)
          );
        });
  }
}
