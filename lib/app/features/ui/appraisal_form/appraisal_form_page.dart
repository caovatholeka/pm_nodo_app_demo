import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/create_appraisal_form.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/apprasial_form_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/birthday_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/comment_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/progress_list_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/project_bar_chart_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/rating_line_chart.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/task_list.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/total_project.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/work_status_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/summary_rating_card.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';



class AppraisalFormPage extends StatefulWidget {
  const AppraisalFormPage({super.key});

  @override
  State<AppraisalFormPage> createState() => _AppraisalFormPageState();
}

class _AppraisalFormPageState extends State<AppraisalFormPage> {  
  

  _createAppraisalForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateAppraisalForm(),
      ),
    );
  }
  final _cubit = GetIt.I.get<ApprasialFormCubit>();

  @override
  void initState() {
    // get detail
    // _cubit.getEvaluationDetails(widget.id);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  } 

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (p, c) => p.totalUnread != c.totalUnread,
        builder: (context, state) {
          return MyAppBar(
            titleAppbar: 'Chất lượng công việc',
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icFlush,
            actionCallBack: () {
              _createAppraisalForm();
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ApprasialFormCubit,ApprasialFormState>(
        bloc: _cubit,
        buildWhen: (prev,cur) => prev.loadDataStatus != cur.loadDataStatus
            || prev.detailEvaluation != cur.detailEvaluation ,
        builder: (context,state){
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children:[
                WorkStatusCard(),
                SizedBox(height: 12,),
                SummaryRatingCard(listTasks: state.detailEvaluation?.taskLineIds ?? [],),
                SizedBox(height: 12),
                RatingSummaryCard(),
                SizedBox(height: 12,),
                // ProgressListCard(),
                TaskList(),
                SizedBox(height: 12),
                TotalProject(),
                SizedBox(height: 12),
                BirthdayCard(),
                SizedBox(height: 12,),
                AttendanceData(),
                
                // CommentCard(
                //     projectTitle: 'PM NODO',
                //     userName: 'Thangtn',
                //     userAvatar: AppAssets.img_df_avatar,
                //     commentText: 'This is a sample comment.'
                // )
              ],
            ),
          );
        });
  }
}
