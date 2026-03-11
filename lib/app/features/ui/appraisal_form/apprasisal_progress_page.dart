import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/create_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_opinion.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_responsibility.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_result_work.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_skill.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

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
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];

  final TextEditingController _jobCtrl = TextEditingController();
  final TextEditingController _coefCtrl = TextEditingController();
  final TextEditingController _evidenceCtrl = TextEditingController();
  List<TaskLineIdEntity> listTasks = [];

  final List<List<TextEditingController>> _evidencesPerStep = [
    [TextEditingController(), TextEditingController(), TextEditingController()],
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
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

  void _fillDetailStep1(CreateAppraisalState state) {
    final task = state.detailEvaluation?.taskLineIds?.firstOrNull;

    if (task == null) return;

    listTasks = state.detailEvaluation?.taskLineIds ?? [];

    _jobCtrl.text = task.name ?? "";
    _coefCtrl.text = task.rate?.toString() ?? "";
    _evidenceCtrl.text = task.jiraKey ?? "";

    // _ratingsPerStep[0][0] = _toInt(task.volume);
    // _ratingsPerStep[0][1] = _toInt(task.quality);
    // _ratingsPerStep[0][2] = _toInt(task.progress);
  }

  void _fillDetailStep2(CreateAppraisalState state) {
    final responses = state.detailEvaluation?.responseIds;

    if (responses == null || responses.isEmpty) return;

    for (int i = 0; i < responses.length; i++) {
      final r = responses[i];
      _ratingsPerStep[1][i] = _toInt(r.ratePoint);
      _evidencesPerStep[1][i].text = r.note ?? "";
    }
  }

  void _fillDetailStep3(CreateAppraisalState state) {
    final skills = state.detailEvaluation?.skillIds;

    if (skills == null || skills.isEmpty) return;

    for (int i = 0; i < skills.length; i++) {
      final skill = skills[i];

      _ratingsPerStep[2][i] = _toInt(skill.ratePoint);

      _evidencesPerStep[2][i].text = skill.note ?? "";
    }
  }

  void _fillDetailStep4(CreateAppraisalState state) {
    final suggests = state.detailEvaluation?.suggestIds;

    if (suggests == null || suggests.isEmpty) return;

    _suggestControllers.clear();

    for (final item in suggests) {
      _suggestControllers.add(TextEditingController(text: item.note ?? ""));
    }
  }

  void _next() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
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

  Widget _buildStepContent(bool isDetail, CreateAppraisalState state) {
    if (_currentStep == 0) {
      return AppraisalStepResultWork(
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
      );
    }

    return AppraisalStepOpinion(
      suggests: state.detailEvaluation?.suggestIds ?? [],
      controllers: _suggestControllers,
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
            _fillDetailStep1(state);
            _fillDetailStep2(state);
            _fillDetailStep3(state);
            _fillDetailStep4(state);
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
              // Positioned.fill(
              //   child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              // ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 16,),
                      _buildStepper(),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              _buildHeaderByStep(),

                              _buildStepContent(isDetail, state),
                            ],
                          ),
                        ),
                      ),

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
}
