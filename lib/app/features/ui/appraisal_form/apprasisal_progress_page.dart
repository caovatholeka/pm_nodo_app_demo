import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_opinion.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_responsibility.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_result_work.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_skill.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class ApprasisalProgressPage extends StatefulWidget {
  const ApprasisalProgressPage({super.key});

  @override
  State<ApprasisalProgressPage> createState() => _ApprasisalProgressPageState();
}

class _ApprasisalProgressPageState extends State<ApprasisalProgressPage> {
  int _currentStep = 0;

  final List<List<int>> _ratingsPerStep = [
    [0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];

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

  final TextEditingController _coefCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();

  @override
  void dispose() {
    for (final group in _evidencesPerStep) {
      for (final c in group) {
        c.dispose();
      }
    }
    _coefCtrl.dispose();
    _totalCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  bool get _canNext {
    if (_currentStep <= 2) {
      final ratings = _ratingsPerStep[_currentStep];
      return ratings.every((r) => r > 0);
    } else {
      return _summaryCtrl.text.trim().isNotEmpty;
    }
  }

Widget _buildStepper() {
  const double circleSize = 26;
  const double lineWidth = 80;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        final showNumber = index <= _currentStep;

        return Row(
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? const Color(0xFF2E87FF)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E87FF),
                  width: 2,
                ),
              ),
              child: Center(
                child: showNumber
                    ? Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive || isCompleted
                              ? Colors.white
                              : const Color(0xFF2E87FF),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (index < 3)
              Container(
                width: lineWidth,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isCompleted
                    ? const Color(0xFF2E87FF)
                    : const Color(0xFF2E87FF).withOpacity(0.25),
              ),
          ],
        );
      }),
    ),
  );
}


Widget _buildStepContent() {
  if (_currentStep == 0) {
    return AppraisalStepResultWork(
      ratings: _ratingsPerStep[0],
      onRate: (i, v) => setState(() => _ratingsPerStep[0][i] = v),
    );
  }

  if (_currentStep == 1) {
    return AppraisalStepResponsibility(
      ratings: _ratingsPerStep[1],
      evidences: _evidencesPerStep[1],
      onRate: (i, v) => setState(() => _ratingsPerStep[1][i] = v),
    );
  }

  if (_currentStep == 2) {
    return AppraisalStepSkill(
      ratings: _ratingsPerStep[2],
      evidences: _evidencesPerStep[2],
      onRate: (i, v) => setState(() => _ratingsPerStep[2][i] = v),
    );
  }

  return AppraisalStepOpinion(
    controller: _summaryCtrl,
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
              isRequiredField: false,
              controller: _coefCtrl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputTextField(
              title: '',
              hintText: 'Tổng điểm',
              isRequiredField: false,
              controller: _totalCtrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondHeaderProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: InputTextField(
              title: '',
              hintText: 'Tổng điểm',
              isRequiredField: false,
              controller: _totalCtrl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderByStep() {
    if (_currentStep == 0) {
      return _headerProgress();
    }

    if(_currentStep == 1) {
      return _secondHeaderProgress();
    }

    if(_currentStep == 2) {
      return _secondHeaderProgress();
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final String actionText = _currentStep < 3 ? 'Tiếp theo' : 'Xác nhận';
    return Scaffold(
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
                  child: MyAppBar(
                    titleAppbar: 'Phiếu đánh giá kết quả CV',
                    haveBackButton: true,
                    haveActionButton: true,
                    iconPathAsset: AppAssets.icNotificationBell,
                    actionCallBack: () {},
                  ),
                ),
                _buildStepper(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _buildHeaderByStep(),
                        _buildStepContent(),

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
        ],
      ),
    );
  }
}
