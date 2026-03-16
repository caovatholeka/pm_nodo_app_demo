import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_opinion.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_responsibility.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_result_work.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_skill.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

import '../../../core/commons/app_colors.dart';
import '../../../data/models/entities/task_line_id_entity.dart';

class ApprasisalProgressPage extends StatefulWidget {
  const ApprasisalProgressPage({super.key});

  @override
  State<ApprasisalProgressPage> createState() => _ApprasisalProgressPageState();
}

class _ApprasisalProgressPageState extends State<ApprasisalProgressPage> {
  int _currentStep = 0;
  bool _initDetail = false;

  final List<List<int>> _ratingsPerStep = [
    [0, 0, 0],
    [],
    [],
  ];

  final TextEditingController _jobCtrl = TextEditingController();
  final TextEditingController _coefCtrl = TextEditingController();
  final TextEditingController _evidenceCtrl = TextEditingController();
  List<TaskLineIdEntity> listTasks = [];

  final List<List<TextEditingController>> _evidencesPerStep = [
    [TextEditingController(), TextEditingController(), TextEditingController()],
    [],
    [],
  ];

  final List<TextEditingController> _suggestControllers = [];

  final TextEditingController _totalCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();

  int _toInt(dynamic v) {
    if (v == null) return 0;

    if (v is bool) {
      return v ? 1 : 0;
    }

    return int.tryParse(v.toString()) ?? 0;
  }

  String _toDisplayText(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  void _resetStepRatings(int stepIndex) {
    for (int i = 0; i < _ratingsPerStep[stepIndex].length; i++) {
      _ratingsPerStep[stepIndex][i] = 0;
    }
  }

  void _ensureStepCapacity(int stepIndex, int length) {
    while (_ratingsPerStep[stepIndex].length < length) {
      _ratingsPerStep[stepIndex].add(0);
    }
    while (_evidencesPerStep[stepIndex].length < length) {
      _evidencesPerStep[stepIndex].add(TextEditingController());
    }
  }

  void _resetStepEvidences(int stepIndex) {
    for (final controller in _evidencesPerStep[stepIndex]) {
      controller.clear();
    }
  }

  void _fillDetailStep1(CreateAppraisalState state) {
    final task = state.detailEvaluation?.taskLineIds?.firstOrNull;

    listTasks = state.detailEvaluation?.taskLineIds ?? [];

    if (task == null) {
      _jobCtrl.clear();
      _coefCtrl.clear();
      return;
    }

    _jobCtrl.text = task.name ?? "";
    _coefCtrl.text = task.rate?.toString() ?? "";
  }

  void _fillDetailStep2(CreateAppraisalState state, {required bool isLeaderReview}) {
    final responses = state.detailEvaluation?.responseIds;

    _ensureStepCapacity(1, responses?.length ?? 0);
    _resetStepRatings(1);
    _resetStepEvidences(1);

    if (responses == null || responses.isEmpty) return;

    for (int i = 0; i < responses.length; i++) {
      final r = responses[i];
      _ratingsPerStep[1][i] = _toInt(
        isLeaderReview ? r.parentRatePoint : r.ratePoint,
      );
      _evidencesPerStep[1][i].text =
          isLeaderReview ? (r.parentNote ?? "") : (r.note ?? "");
    }
  }

  void _fillDetailStep3(CreateAppraisalState state, {required bool isLeaderReview}) {
    final skills = state.detailEvaluation?.skillIds;

    _ensureStepCapacity(2, skills?.length ?? 0);
    _resetStepRatings(2);
    _resetStepEvidences(2);

    if (skills == null || skills.isEmpty) return;

    for (int i = 0; i < skills.length; i++) {
      final skill = skills[i];

      _ratingsPerStep[2][i] = _toInt(
        isLeaderReview ? skill.parentRatePoint : skill.ratePoint,
      );

      _evidencesPerStep[2][i].text =
          isLeaderReview ? (skill.parentNote ?? "") : (skill.note ?? "");
    }
  }

  void _fillDetailStep4(CreateAppraisalState state) {
    final suggests = state.detailEvaluation?.suggestIds;

    _suggestControllers.clear();

    if (suggests == null || suggests.isEmpty) return;

    for (final item in suggests) {
      _suggestControllers.add(TextEditingController(text: item.note ?? ""));
    }
  }

  void _fillTotalByStep(CreateAppraisalState state, {required bool isLeaderReview}) {
    final detail = state.detailEvaluation;
    if (detail == null) {
      _totalCtrl.clear();
      return;
    }

    if (_currentStep == 0) {
      _totalCtrl.text = _toDisplayText(
        isLeaderReview ? detail.totalParentTaskScore : detail.totalTaskScore,
      );
      return;
    }

    if (_currentStep == 1) {
      _totalCtrl.text = _toDisplayText(
        isLeaderReview
            ? detail.responseParentTotalScore
            : detail.responseTotalScore,
      );
      return;
    }

    if (_currentStep == 2) {
      _totalCtrl.text = _toDisplayText(
        isLeaderReview ? detail.skillParentTotalScore : detail.skillTotalScore,
      );
      return;
    }

    _totalCtrl.clear();
  }

  void _next() {
    final cubit = context.read<CreateAppraisalCubit>();
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        _fillTotalByStep(
          cubit.state,
          isLeaderReview: cubit.state.currentTabIndex == 1,
        );
      });
    } else {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }
  }

  void _back() {
    final cubit = context.read<CreateAppraisalCubit>();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _fillTotalByStep(
          cubit.state,
          isLeaderReview: cubit.state.currentTabIndex == 1,
        );
      });
    } else {
      Navigator.pop(context);
    }
  }

  // bool get _canNext {
  //   if (_currentStep <= 2) {
  //     final ratings = _ratingsPerStep[_currentStep];
  //     return ratings.every((r) => r > 0);
  //   }
  //   return true;
  // }
  bool get _canNext => true;

  Widget _buildStepper() {
    const circleSize = 26.0;
    const lineWidth = 60.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color:
                      isActive || isCompleted
                          ? const Color(0xFF2E87FF)
                          : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E87FF), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive || isCompleted
                              ? Colors.white
                              : const Color(0xFF2E87FF),
                    ),
                  ),
                ),
              ),

              if (index < 3)
                Container(
                  width: lineWidth,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color:
                      isCompleted
                          ? const Color(0xFF2E87FF)
                          : const Color(0xFF2E87FF).withValues(alpha: 0.25),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepperLeaderReview() {
    const circleSize = 26.0;
    const lineWidth = 60.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color:
                  isActive || isCompleted
                      ? const Color(0xFF7030A0)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7030A0), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                      isActive || isCompleted
                          ? Colors.white
                          : const Color(0xFF7030A0),
                    ),
                  ),
                ),
              ),

              if (index < 3)
                Container(
                  width: lineWidth,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color:
                  isCompleted
                      ? const Color(0xFF7030A0)
                      : const Color(0xFF7030A0).withValues(alpha: 0.25),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _headerProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: InputTextField(
              title: '',
              hintText: 'Hệ số',
              controller: _coefCtrl,
              readOnly: true,
              isRequiredField: false,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: InputTextField(
              title: '',
              hintText: 'Tổng điểm',
              controller: _totalCtrl,
              readOnly: true,
              isRequiredField: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InputTextField(
        title: '',
        hintText: 'Tổng điểm',
        controller: _totalCtrl,
        isRequiredField: false,
      ),
    );
  }

  Widget _buildHeaderByStep() {
    if (_currentStep == 0) return _headerProgress();
    if (_currentStep == 1) return _secondHeader();
    if (_currentStep == 2) return _secondHeader();

    return const SizedBox.shrink();
  }

  void _syncTabData(CreateAppraisalState state, {required bool isLeaderReview}) {
    _fillDetailStep1(state);
    _fillDetailStep2(state, isLeaderReview: isLeaderReview);
    _fillDetailStep3(state, isLeaderReview: isLeaderReview);
    _fillDetailStep4(state);
    _fillTotalByStep(state, isLeaderReview: isLeaderReview);
  }

  Widget _buildStepContent(bool isDetail, CreateAppraisalState state, bool isLeaderReview) {
    if (_currentStep == 0) {
      return AppraisalStepResultWork(
        isLeaderReview: isLeaderReview,
        listTask: listTasks,
        ratings: _ratingsPerStep[0],
        jobCtrl: _jobCtrl,
        weightCtrl: _coefCtrl,
        evidenceCtrl: _evidenceCtrl,
        readOnly: isDetail,
        onRate: (i, v) {
          setState(() {
            _ratingsPerStep[0][i] = v;
          });
        },
      );
    }

    if (_currentStep == 1) {
      return AppraisalStepResponsibility(
        responses: state.detailEvaluation?.responseIds ?? [],
        ratings: _ratingsPerStep[1],
        evidences: _evidencesPerStep[1],
        onRate: (i, v) {
          setState(() {
            _ratingsPerStep[1][i] = v;
          });
        },
        isLeaderReview: isLeaderReview
      );
    }

    if (_currentStep == 2) {
      return AppraisalStepSkill(
        skills: state.detailEvaluation?.skillIds ?? [],
        ratings: _ratingsPerStep[2],
        evidences: _evidencesPerStep[2],
        onRate: (i, v) {
          setState(() {
            _ratingsPerStep[2][i] = v;
          });
        },
        isLeaderReview: isLeaderReview
      );
    }

    return AppraisalStepOpinion(
      suggests: state.detailEvaluation?.suggestIds ?? [],
      controllers: _suggestControllers,
      isLeaderReview: isLeaderReview
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAppraisalCubit, CreateAppraisalState>(
      builder: (context, state) {
        final isDetail = state.isDetail == true;

        if (!_initDetail && state.detailEvaluation != null) {
          _initDetail = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncTabData(
              state,
              isLeaderReview: state.currentTabIndex == 1,
            );
            setState(() {});
          });
        }

        final actionText = _currentStep < 3 ? 'Tiếp theo' : 'Xác nhận';

        return Scaffold(
          appBar: MyAppBar(
            titleAppbar: 'Phiếu đánh giá kết quả CV',
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icNotificationBell,
            actionCallBack: () {},
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 16,),
                      // tabbar
                      _buildTabBar(),
                      const SizedBox(height: 8,),

                      // phiếu đánh giá
                      BlocBuilder<CreateAppraisalCubit,CreateAppraisalState>(
                          buildWhen: (prev,cur) =>
                            prev.currentTabIndex != cur.currentTabIndex ||
                            prev.currentTabItem != cur.currentTabItem,
                          builder: (context,state) {
                            return state.currentTabIndex == 0 ?
                            Expanded(
                              child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        _buildStepper(),
                                        const SizedBox(height: 8),
                                        _buildHeaderByStep(),
                                        _buildStepContent(isDetail, state,false),
                                      ],
                                    ),
                                  ),
                            ) :
                            Expanded(
                              child: SingleChildScrollView(
                                    child: Column(children: [
                                      _buildStepperLeaderReview(),
                                      const SizedBox(height: 8),
                                      _buildHeaderByStep(),
                                      _buildStepContent(isDetail, state, true),
                                    ],),
                                  ),
                            );
                          }),

                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  mainText: 'Quay lại',
                                  enable: true,
                                  isLoading: false,
                                  type: PrimaryButtonType.secondary,
                                  callback: _back,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: PrimaryButton(
                                  mainText: actionText,
                                  enable: _canNext,
                                  isLoading: false,
                                  callback: _next,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTabBar() {
    List<MasterDataItem> tabs = [
      MasterDataItem(text: "Phiếu đánh giá",id:0),
      MasterDataItem(text: "Cấp trên trực tiếp",id:1),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<CreateAppraisalCubit,CreateAppraisalState>(
          buildWhen: (prev,cur) => prev.currentTabIndex != cur.currentTabIndex,
          builder: (context,state){
            return Row(
              children: List.generate(tabs.length, (index) {
                final item = tabs[index];
                final isSelected = index == state.currentTabIndex;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 0 ? 4 : 0,
                      left: index == tabs.length - 1 ? 4 : 0,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: (){
                        final cubit = context.read<CreateAppraisalCubit>();
                        if (index != cubit.state.currentTabIndex) {
                          cubit.onChangeTab(index);
                          cubit.onChangeCurrentTabItem(item);
                          _syncTabData(
                            cubit.state,
                            isLeaderReview: index == 1,
                          );
                          setState(() {});
                        }},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF3F3F5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          item.text ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF0A84FF)
                                : const Color(0xFF3A3A3C),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
    );
  }
}
