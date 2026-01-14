import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/create_appraisal_form.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/comment_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/rating_line_chart.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../widgets/summary_rating_card.dart';
import '../widgets/progress_list_card.dart';
import '../widgets/project_bar_chart_card.dart';

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
            titleAppbar: 'Đánh giá kết quả công việc',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children:[
          SummaryRatingCard(),
          SizedBox(height: 12),
          ProgressListCard(),
          SizedBox(height: 12),
          ProjectBarChartCard(),
          SizedBox(height: 12),
          RatingLineChartCard(),
          SizedBox(height: 12),
          CommentCard(
            projectTitle: 'PM NODO', 
            userName: 'Thangtn',
            userAvatar: AppAssets.img_df_avatar,
             commentText: 'This is a sample comment.'
             )
        ],
      ),
    );
  }
}
