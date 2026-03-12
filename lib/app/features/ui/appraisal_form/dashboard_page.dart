import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/birthday_list_detail.dart';
import 'package:pm_app/app/features/ui/appraisal_form/create_appraisal_form.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/discipline_evaluation_detail.dart';
import 'package:pm_app/app/features/ui/appraisal_form/projects_detail.dart';
import 'package:pm_app/app/features/ui/appraisal_form/timesheet_data_detail.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/attendance_data.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/birthday_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/rating_line_chart.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/summary_rating_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/task_list.dart';

import 'package:pm_app/app/features/ui/appraisal_form/widgets/total_project.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/work_status_card.dart';
import 'package:pm_app/app/features/ui/appraisal_form/work_quality_detail.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _cubit = GetIt.I.get<DashboardCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getRequestSummaries();
    _cubit.getProjects();
    _cubit.getTodayTasks();
    _cubit.getProjectTasks();
    _cubit.getTimeSheetData(DateTime.now().month);
    _cubit.getBirthdaysThisMonth(DateTime.now().month);
  }

  void _createAppraisalForm() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateAppraisalForm()));
  }

  void _goWorkQuality() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WorkQualityDetail()));
  }
  
  void _goDisciplineEvaluationDetail() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DisciplineEvaluationDetail()));
  }

  void _goProject() {
    Navigator.of(context).push(MaterialPageRoute(builder:(_) => const ProjectsDetail()));
  }

  void _goBirthdayList() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BirthdayListDetail()));
  }

  void _goTimeSheetData() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimesheetDataDetail()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<AppCubit, AppState>(
                      buildWhen: (p, c) => p.totalUnread != c.totalUnread,
                      builder: (context, state) {
                        return MyAppBar(
                          titleAppbar: 'Chất lượng công việc',
                          haveBackButton: true,
                          haveActionButton: false,
                          iconPathAsset: AppAssets.icFlush,
                          actionCallBack: _createAppraisalForm,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          const WorkStatusCard(),
                          const SizedBox(height: 12),
                          SummaryRatingCard(onTap: () => _goWorkQuality()),
                          SizedBox(height: 12),
                          RatingSummaryCard(
                            onTap: () {
                              _goDisciplineEvaluationDetail();
                            },
                          ),
                          SizedBox(height: 12),
                          TaskList(),
                          SizedBox(height: 12),
                          TotalProject(
                            onTap: () {
                              _goProject();
                            },
                          ),
                          SizedBox(height: 12),
                          BirthdayCard(
                            onTap: () {
                              _goBirthdayList();
                            },
                          ),
                          SizedBox(height: 12),
                          AttendanceData(
                            onTap: () => _goTimeSheetData(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
