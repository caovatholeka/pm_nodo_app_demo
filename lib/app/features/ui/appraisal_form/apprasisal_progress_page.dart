import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/data/models/entities/skill_id_entity.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/data/models/entities/task_line_id_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/detail_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_opinion.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_responsibility.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_result_work.dart';
import 'package:pm_app/app/features/ui/appraisal_form/steps/appraisal_step_skill.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class ApprasisalProgressPage extends StatefulWidget {
  const ApprasisalProgressPage({super.key});

  @override
  State<ApprasisalProgressPage> createState() => _ApprasisalProgressPageState();
}

class _ApprasisalProgressPageState extends State<ApprasisalProgressPage> {
  int _currentStep = 0;
  bool _didHydrateDetail = false;
  bool _didInitializeCreate = false;
  bool _showCoefError = false;

  bool get _showLegacyCoefError => false;
  static const List<double> _responseCoefficients = [2, 2, 1.5, 2, 0.5];
  static const List<double> _skillCoefficients = [1, 1, 0.5, 0.5, 1];

  List<TaskLineIdEntity> _taskItems = [];
  List<ResponsiveIdEntity> _responseItems = [];
  List<SkillIdEntity> _skillItems = [];
  List<SuggestIdEntity> _suggestItems = [];

  final List<TextEditingController> _taskEvidenceControllers = [];
  final List<TextEditingController> _taskNameControllers = [];
  final List<TextEditingController> _taskRateControllers = [];
  final List<TextEditingController> _leaderTaskEvidenceControllers = [];
  final List<TextEditingController> _responseEvidenceControllers = [];
  final List<TextEditingController> _leaderResponseEvidenceControllers = [];
  final List<TextEditingController> _skillEvidenceControllers = [];
  final List<TextEditingController> _leaderSkillEvidenceControllers = [];
  final List<TextEditingController> _suggestControllers = [];

  final TextEditingController _coefCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();

  int _totalTaskRate(List<TaskLineIdEntity> tasks) {
    return tasks.fold<int>(0, (sum, task) => sum + (task.rate ?? 0));
  }

  bool _hasValidTaskRateTotal() => _totalTaskRate(_taskItems) == 100;

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double _taskAverage(TaskLineIdEntity task, bool isLeaderReview) {
    final volume = _toDouble(isLeaderReview ? task.parentVolume : task.volume);
    final quality = _toDouble(
      isLeaderReview ? task.parentQuality : task.quality,
    );
    final progress = _toDouble(
      isLeaderReview ? task.parentProgress : task.progress,
    );
    return (volume + quality + progress) / 3;
  }

  double _responseCoefficientAt(int index) {
    if (index < _responseCoefficients.length) {
      return _responseCoefficients[index];
    }
    return 2;
  }

  double _skillCoefficientAt(int index) {
    if (index < _skillCoefficients.length) {
      return _skillCoefficients[index];
    }
    return 1;
  }

  double _computeTaskTotalScore(bool isLeaderReview) {
    final weightedAverage = _taskItems.fold<double>(0, (sum, task) {
      final rate = _toDouble(task.rate);
      return sum + (_taskAverage(task, isLeaderReview) * rate / 100);
    });
    return weightedAverage * 14;
  }

  double _computeResponseTotalScore(bool isLeaderReview) {
    double total = 0;
    for (int index = 0; index < _responseItems.length; index++) {
      final item = _responseItems[index];
      final rate = _toDouble(
        isLeaderReview ? item.parentRatePoint : item.ratePoint,
      );
      total += rate * _responseCoefficientAt(index);
    }
    return total / 2;
  }

  double _computeSkillTotalScore(bool isLeaderReview) {
    double total = 0;
    for (int index = 0; index < _skillItems.length; index++) {
      final item = _skillItems[index];
      final rate = _toDouble(
        isLeaderReview ? item.parentRatePoint : item.ratePoint,
      );
      total += rate * _skillCoefficientAt(index);
    }
    return total / 2;
  }

  String _formatScore(double value) {
    final normalized = (value * 10).roundToDouble() / 10;
    if (normalized == normalized.truncateToDouble()) {
      return normalized.toStringAsFixed(0);
    }
    return normalized.toStringAsFixed(1);
  }

  void _refreshHeaderTotals() {
    final state = context.read<CreateAppraisalCubit>().state;
    final isCreate = state.isDetail != true && state.isEdit != true;
    final isLeaderReview = !isCreate && state.currentTabIndex == 1;
    _coefCtrl.text = _totalTaskRate(_taskItems).toString();
    _fillTotalByStep(state, isLeaderReview: isLeaderReview);
  }

  String _employeeTaskEvidence(TaskLineIdEntity task) {
    if ((task.jiraKey ?? '').isNotEmpty) {
      return task.jiraKey ?? '';
    }
    return task.note ?? '';
  }

  void _disposeControllers(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
    controllers.clear();
  }

  void _replaceControllers(
    List<TextEditingController> target,
    List<String> values,
  ) {
    _disposeControllers(target);
    for (final value in values) {
      target.add(TextEditingController(text: value));
    }
  }

  void _hydrateDetail(CreateAppraisalState state) {
    final detail = state.detailEvaluation;
    if (detail == null) return;

    _taskItems = [
      for (final item in detail.taskLineIds ?? <TaskLineIdEntity>[])
        item.copyWith(),
    ];
    _responseItems = [
      for (final item in detail.responseIds ?? <ResponsiveIdEntity>[])
        item.copyWith(),
    ];
    _skillItems = [
      for (final item in detail.skillIds ?? <SkillIdEntity>[]) item.copyWith(),
    ];
    _suggestItems = [
      for (final item in detail.suggestIds ?? <SuggestIdEntity>[])
        item.copyWith(),
    ];

    _replaceControllers(
      _taskNameControllers,
      _taskItems.map((item) => item.name ?? '').toList(),
    );
    _replaceControllers(
      _taskRateControllers,
      _taskItems.map((item) => (item.rate ?? 0).toString()).toList(),
    );
    _replaceControllers(
      _taskEvidenceControllers,
      _taskItems.map(_employeeTaskEvidence).toList(),
    );
    _replaceControllers(
      _leaderTaskEvidenceControllers,
      _taskItems.map((item) => item.parentNote ?? '').toList(),
    );
    _replaceControllers(
      _responseEvidenceControllers,
      _responseItems.map((item) => item.note ?? '').toList(),
    );
    _replaceControllers(
      _leaderResponseEvidenceControllers,
      _responseItems.map((item) => item.parentNote ?? '').toList(),
    );
    _replaceControllers(
      _skillEvidenceControllers,
      _skillItems.map((item) => item.note ?? '').toList(),
    );
    _replaceControllers(
      _leaderSkillEvidenceControllers,
      _skillItems.map((item) => item.parentNote ?? '').toList(),
    );
    _replaceControllers(
      _suggestControllers,
      _suggestItems.map((item) => item.note ?? '').toList(),
    );

    _coefCtrl.text = _totalTaskRate(_taskItems).toString();
    _fillTotalByStep(state, isLeaderReview: state.currentTabIndex == 1);
    _didHydrateDetail = true;
  }

  void _initializeCreateDefaults() {
    _taskItems = [TaskLineIdEntity()];
    _responseItems = [
      ResponsiveIdEntity(
        code: 'TN01',
        name: 'Trách nhiệm, thấu đáo trong công việc',
      ),
      ResponsiveIdEntity(
        code: 'TN02',
        name: 'Chấp hành nội quy, quy định chung của Công ty',
      ),
      ResponsiveIdEntity(
        code: 'TN03',
        name: 'Bảo mật thông tin, bảo vệ uy tín Công ty',
      ),
      ResponsiveIdEntity(code: 'TN04', name: 'Tinh thần, thái độ làm việc'),
      ResponsiveIdEntity(
        code: 'TN05',
        name: 'Săn xuất và phân phối công cụ làm việc',
      ),
    ];
    _skillItems = [
      SkillIdEntity(code: 'KN01', name: 'Phối hợp nội bộ'),
      SkillIdEntity(code: 'KN02', name: 'Phối hợp bên ngoài'),
      SkillIdEntity(code: 'KN03', name: 'Thủ tục hành chính, tài chính'),
      SkillIdEntity(code: 'KN04', name: 'Quản lý sắp xếp công việc'),
      SkillIdEntity(
        code: 'KN05',
        name: 'Các kỹ năng khác theo chuyên môn nghiệp vụ',
      ),
    ];
    _suggestItems = [
      SuggestIdEntity(
        code: 'DG01',
        name: 'Ý kiến - Đề xuất của người được đánh giá',
      ),
    ];

    _responseItems = [
      ResponsiveIdEntity(
        code: 'TN01',
        name: 'Trách nhiệm, thấu đáo trong công việc',
      ),
      ResponsiveIdEntity(
        code: 'TN02',
        name: 'Chấp hành nội quy, quy định chung của Công ty',
      ),
      ResponsiveIdEntity(
        code: 'TN03',
        name: 'Bảo mật thông tin, bảo vệ uy tín Công ty',
      ),
      ResponsiveIdEntity(code: 'TN04', name: 'Tinh thần, thái độ làm việc'),
      ResponsiveIdEntity(
        code: 'TN05',
        name: 'Sản xuất và phân phối công cụ làm việc',
      ),
    ];
    _skillItems = [
      SkillIdEntity(code: 'KN01', name: 'Phối hợp nội bộ'),
      SkillIdEntity(code: 'KN02', name: 'Phối hợp bên ngoài'),
      SkillIdEntity(code: 'KN03', name: 'Thủ tục hành chính, tài chính'),
      SkillIdEntity(code: 'KN04', name: 'Quản lý sắp xếp công việc'),
      SkillIdEntity(
        code: 'KN05',
        name: 'Các kỹ năng khác theo chuyên môn nghiệp vụ',
      ),
    ];
    _suggestItems = [
      SuggestIdEntity(
        code: 'DG01',
        name: 'Ý kiến - Đề xuất của người được đánh giá',
      ),
    ];

    _replaceControllers(_taskNameControllers, const ['']);
    _replaceControllers(_taskRateControllers, const ['']);
    _replaceControllers(_taskEvidenceControllers, const ['']);
    _replaceControllers(_leaderTaskEvidenceControllers, const ['']);
    _replaceControllers(
      _responseEvidenceControllers,
      List.filled(_responseItems.length, ''),
    );
    _replaceControllers(
      _leaderResponseEvidenceControllers,
      List.filled(_responseItems.length, ''),
    );
    _replaceControllers(
      _skillEvidenceControllers,
      List.filled(_skillItems.length, ''),
    );
    _replaceControllers(
      _leaderSkillEvidenceControllers,
      List.filled(_skillItems.length, ''),
    );
    _replaceControllers(
      _suggestControllers,
      List.filled(_suggestItems.length, ''),
    );

    _coefCtrl.clear();
    _totalCtrl.clear();
    _didInitializeCreate = true;
  }

  void _fillTotalByStep(
    CreateAppraisalState state, {
    required bool isLeaderReview,
  }) {
    final detail = state.detailEvaluation;
    final useLocalScore = state.isDetail != true;

    if (useLocalScore) {
      if (_currentStep == 0) {
        _totalCtrl.text = _formatScore(_computeTaskTotalScore(isLeaderReview));
        return;
      }

      if (_currentStep == 1) {
        _totalCtrl.text = _formatScore(
          _computeResponseTotalScore(isLeaderReview),
        );
        return;
      }

      if (_currentStep == 2) {
        _totalCtrl.text = _formatScore(_computeSkillTotalScore(isLeaderReview));
        return;
      }

      _totalCtrl.clear();
      return;
    }

    if (detail == null) {
      _totalCtrl.clear();
      return;
    }

    if (_currentStep == 0) {
      _totalCtrl.text =
          (isLeaderReview ? detail.totalParentTaskScore : detail.totalTaskScore)
              ?.toString() ??
          '';
      return;
    }

    if (_currentStep == 1) {
      _totalCtrl.text =
          (isLeaderReview
                  ? detail.responseParentTotalScore
                  : detail.responseTotalScore)
              ?.toString() ??
          '';
      return;
    }

    if (_currentStep == 2) {
      _totalCtrl.text =
          (isLeaderReview
                  ? detail.skillParentTotalScore
                  : detail.skillTotalScore)
              ?.toString() ??
          '';
      return;
    }

    _totalCtrl.clear();
  }

  List<TextEditingController> _taskControllersForTab(bool isLeaderReview) {
    return isLeaderReview
        ? _leaderTaskEvidenceControllers
        : _taskEvidenceControllers;
  }

  List<TextEditingController> _responseControllersForTab(bool isLeaderReview) {
    return isLeaderReview
        ? _leaderResponseEvidenceControllers
        : _responseEvidenceControllers;
  }

  List<TextEditingController> _skillControllersForTab(bool isLeaderReview) {
    return isLeaderReview
        ? _leaderSkillEvidenceControllers
        : _skillEvidenceControllers;
  }

  void _updateTaskRating(
    bool isLeaderReview,
    int taskIndex,
    int ratingIndex,
    int value,
  ) {
    final current = _taskItems[taskIndex];
    TaskLineIdEntity updated;

    if (isLeaderReview) {
      switch (ratingIndex) {
        case 0:
          updated = current.copyWith(parentVolume: value);
          break;
        case 1:
          updated = current.copyWith(parentQuality: value);
          break;
        default:
          updated = current.copyWith(parentProgress: value);
      }
    } else {
      switch (ratingIndex) {
        case 0:
          updated = current.copyWith(volume: value);
          break;
        case 1:
          updated = current.copyWith(quality: value);
          break;
        default:
          updated = current.copyWith(progress: value);
      }
    }

    setState(() {
      _taskItems[taskIndex] = updated;
      _refreshHeaderTotals();
    });
  }

  void _updateTaskName(int index, String value) {
    final current = _taskItems[index];
    setState(() {
      _taskItems[index] = current.copyWith(name: value);
    });
  }

  void _updateTaskRate(int index, String value) {
    final parsed = int.tryParse(value.trim());
    final current = _taskItems[index];
    setState(() {
      _taskItems[index] = current.copyWith(rate: parsed ?? current.rate);
      _refreshHeaderTotals();
      if (_showCoefError && _hasValidTaskRateTotal()) {
        _showCoefError = false;
      }
    });
  }

  void _updateResponseRating(bool isLeaderReview, int index, int value) {
    final current = _responseItems[index];
    setState(() {
      _responseItems[index] =
          isLeaderReview
              ? current.copyWith(parentRatePoint: value)
              : current.copyWith(ratePoint: value);
      _refreshHeaderTotals();
    });
  }

  void _updateSkillRating(bool isLeaderReview, int index, int value) {
    final current = _skillItems[index];
    setState(() {
      _skillItems[index] =
          isLeaderReview
              ? current.copyWith(parentRatePoint: value)
              : current.copyWith(ratePoint: value);
      _refreshHeaderTotals();
    });
  }

  void _addTaskCriteria() {
    setState(() {
      _taskItems = [..._taskItems, TaskLineIdEntity()];
      _taskNameControllers.add(TextEditingController());
      _taskRateControllers.add(TextEditingController());
      _taskEvidenceControllers.add(TextEditingController());
      _leaderTaskEvidenceControllers.add(TextEditingController());
      _refreshHeaderTotals();
    });
  }

  // ignore: unused_element
  void _addResponseCriteria() {
    final nextNumber = _responseItems.length + 1;
    final code = 'TN${nextNumber.toString().padLeft(2, '0')}';

    setState(() {
      _responseItems = [
        ..._responseItems,
        ResponsiveIdEntity(code: code, name: 'Tiêu chí bổ sung $nextNumber'),
      ];
      _responseEvidenceControllers.add(TextEditingController());
      _leaderResponseEvidenceControllers.add(TextEditingController());
    });
  }

  String _textAt(List<TextEditingController> controllers, int index) {
    if (index < 0 || index >= controllers.length) return '';
    return controllers[index].text.trim();
  }

  String? _nullableTextAt(List<TextEditingController> controllers, int index) {
    final value = _textAt(controllers, index);
    return value.isEmpty ? null : value;
  }

  Map<String, dynamic>? _buildUpdatePayload(CreateAppraisalState state) {
    final detail = state.detailEvaluation;
    if (detail == null) return null;

    final taskLineIds = List.generate(_taskItems.length, (index) {
      final item = _taskItems[index];
      return <String, dynamic>{
        "name": item.name,
        "rate": item.rate,
        "volume": item.volume,
        "quality": item.quality,
        "progress": item.progress,
        "note": _nullableTextAt(_taskEvidenceControllers, index),
        "parent_volume": item.parentVolume,
        "parent_quality": item.parentQuality,
        "parent_progress": item.parentProgress,
        "parent_note": _nullableTextAt(_leaderTaskEvidenceControllers, index),
      };
    });

    final responseIds = List.generate(_responseItems.length, (index) {
      final item = _responseItems[index];
      return <String, dynamic>{
        "id": item.id,
        "code": item.code,
        "name": item.name,
        "rate_point": item.ratePoint,
        "parent_rate_point": item.parentRatePoint,
        "note": _nullableTextAt(_responseEvidenceControllers, index),
        "parent_note": _nullableTextAt(
          _leaderResponseEvidenceControllers,
          index,
        ),
      };
    });

    final skillIds = List.generate(_skillItems.length, (index) {
      final item = _skillItems[index];
      return <String, dynamic>{
        "code": item.code,
        "name": item.name,
        "rate_point": item.ratePoint,
        "parent_rate_point": item.parentRatePoint,
        "note": _nullableTextAt(_skillEvidenceControllers, index),
        "parent_note": _nullableTextAt(_leaderSkillEvidenceControllers, index),
      };
    });

    final suggestIds = List.generate(_suggestItems.length, (index) {
      final item = _suggestItems[index];
      return <String, dynamic>{
        "code": item.code,
        "name": item.name,
        "note": _nullableTextAt(_suggestControllers, index),
      };
    });

    return <String, dynamic>{
      "employee_id": detail.employeeId,
      "date_from": detail.dateFrom,
      "date_to": detail.dateTo,
      "task_line_ids": taskLineIds,
      "response_ids": responseIds,
      "skill_ids": skillIds,
      "suggest_ids": suggestIds,
    };
  }

  EvaluationEntity? _buildCreatePayload(CreateAppraisalState state) {
    final employeeId = GlobalData.instance.userProfile?.employeeId;
    final fromDate = state.fromDate;
    final toDate = state.toDate;

    if (employeeId == null || fromDate == null || toDate == null) {
      return null;
    }

    final formatter = DateFormat('yyyy-MM-dd');

    final taskLineIds = List.generate(_taskItems.length, (index) {
      final item = _taskItems[index];
      return item.copyWith(
        note: _nullableTextAt(_taskEvidenceControllers, index),
        parentNote: _nullableTextAt(_leaderTaskEvidenceControllers, index),
      );
    });

    final responseIds = List.generate(_responseItems.length, (index) {
      final item = _responseItems[index];
      return item.copyWith(
        note: _nullableTextAt(_responseEvidenceControllers, index),
        parentNote: _nullableTextAt(_leaderResponseEvidenceControllers, index),
      );
    });

    final skillIds = List.generate(_skillItems.length, (index) {
      final item = _skillItems[index];
      return item.copyWith(
        note: _nullableTextAt(_skillEvidenceControllers, index),
        parentNote: _nullableTextAt(_leaderSkillEvidenceControllers, index),
      );
    });

    final suggestIds = List.generate(_suggestItems.length, (index) {
      final item = _suggestItems[index];
      return item.copyWith(note: _nullableTextAt(_suggestControllers, index));
    });

    return EvaluationEntity(
      employeeId: employeeId,
      dateFrom: formatter.format(fromDate),
      dateTo: formatter.format(toDate),
      note: state.note,
      taskLineIds: taskLineIds,
      responseIds: responseIds,
      skillIds: skillIds,
      suggestIds: suggestIds,
    );
  }

  void _submitUpdate(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    final payload = _buildUpdatePayload(state);
    if (id == 0 || payload == null) return;
    context.read<CreateAppraisalCubit>().updateEvaluation(id, payload);
  }

  void _submitCreate(CreateAppraisalState state) {
    final payload = _buildCreatePayload(state);
    if (payload == null) return;
    context.read<CreateAppraisalCubit>().createEvaluation(payload);
  }

  void _closeFlow(EvaluationEntity? updatedEvaluation) {
    Navigator.pop(context);
    Navigator.pop(context, updatedEvaluation);
  }

  void _next() {
    final cubit = context.read<CreateAppraisalCubit>();
    final state = cubit.state;
    final isDetail = state.isDetail == true;
    final isCreate = !isDetail && state.isEdit != true;
    final isLeaderReview = !isCreate && state.currentTabIndex == 1;

    if (!isDetail &&
        !isLeaderReview &&
        _currentStep == 0 &&
        !_hasValidTaskRateTotal()) {
      setState(() {
        _showCoefError = true;
      });
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        _showCoefError = false;
        _fillTotalByStep(state, isLeaderReview: state.currentTabIndex == 1);
      });
      return;
    }

    if (state.isEdit == true) {
      _submitUpdate(state);
      return;
    }

    if (state.isDetail == true) {
      _closeFlow(null);
      return;
    }

    _submitCreate(state);
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

  Widget _headerProgress(S s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputTextField(
                  title: '',
                  hintText: s.appraisal_coefficient,
                  controller: _coefCtrl,
                  readOnly: true,
                  isRequiredField: false,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 16,
                  child:
                      _showCoefError
                          ? const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              'Tổng hệ số phải bằng 100%',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                if (_showLegacyCoefError && _showCoefError) ...[
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Tổng hệ số phải bằng 100%',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputTextField(
              title: '',
              hintText: s.appraisal_total_score,
              controller: _totalCtrl,
              readOnly: true,
              isRequiredField: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondHeader(S s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InputTextField(
        title: '',
        hintText: s.appraisal_total_score,
        controller: _totalCtrl,
        readOnly: true,
        isRequiredField: false,
      ),
    );
  }

  Widget _buildHeaderByStep(S s) {
    if (_currentStep == 0) return _headerProgress(s);
    if (_currentStep == 1 || _currentStep == 2) return _secondHeader(s);
    return const SizedBox.shrink();
  }

  Widget _buildStepContent(
    bool isDetail,
    CreateAppraisalState state,
    bool isLeaderReview,
  ) {
    if (_currentStep == 0) {
      return AppraisalStepResultWork(
        isLeaderReview: isLeaderReview,
        listTask: _taskItems,
        nameControllers: _taskNameControllers,
        rateControllers: _taskRateControllers,
        evidenceControllers: _taskControllersForTab(isLeaderReview),
        readOnly: isDetail,
        onAddCriteria: (!isDetail && !isLeaderReview) ? _addTaskCriteria : null,
        onNameChanged: _updateTaskName,
        onTaskRateChanged: _updateTaskRate,
        onRate:
            (taskIndex, ratingIndex, value) => _updateTaskRating(
              isLeaderReview,
              taskIndex,
              ratingIndex,
              value,
            ),
      );
    }

    if (_currentStep == 1) {
      return AppraisalStepResponsibility(
        responses: _responseItems,
        evidences: _responseControllersForTab(isLeaderReview),
        readOnly: isDetail,
        onRate: (index, value) {
          _updateResponseRating(isLeaderReview, index, value);
        },
        isLeaderReview: isLeaderReview,
      );
    }

    if (_currentStep == 2) {
      return AppraisalStepSkill(
        skills: _skillItems,
        evidences: _skillControllersForTab(isLeaderReview),
        readOnly: isDetail,
        onRate: (index, value) {
          _updateSkillRating(isLeaderReview, index, value);
        },
        isLeaderReview: isLeaderReview,
      );
    }

    return AppraisalStepOpinion(
      suggests: _suggestItems,
      controllers: _suggestControllers,
      isLeaderReview: isLeaderReview,
      readOnly: isDetail,
      evaluationState: state.detailEvaluation?.state,
    );
  }

  @override
  void dispose() {
    _coefCtrl.dispose();
    _totalCtrl.dispose();
    _disposeControllers(_taskNameControllers);
    _disposeControllers(_taskRateControllers);
    _disposeControllers(_taskEvidenceControllers);
    _disposeControllers(_leaderTaskEvidenceControllers);
    _disposeControllers(_responseEvidenceControllers);
    _disposeControllers(_leaderResponseEvidenceControllers);
    _disposeControllers(_skillEvidenceControllers);
    _disposeControllers(_leaderSkillEvidenceControllers);
    _disposeControllers(_suggestControllers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<CreateAppraisalCubit, CreateAppraisalState>(
      listenWhen: (prev, cur) => prev.updateStatus != cur.updateStatus,
      listener: (context, state) {
        if (state.updateStatus == LoadStatus.SUCCESS) {
          AppSnackBar.showInfo(
            title: s.success,
            message: state.errMsg?.isNotEmpty == true ? state.errMsg : s.save,
          );
          context.read<CreateAppraisalCubit>().resetUpdateStatus();
          _closeFlow(
            state.detailEvaluation ??
                (state.isEdit == true || state.isDetail == true
                    ? null
                    : _buildCreatePayload(state)),
          );
          return;
        }

        if (state.updateStatus == LoadStatus.FAILURE) {
          AppSnackBar.showError(
            title: s.warning,
            message:
                state.errMsg?.isNotEmpty == true
                    ? state.errMsg
                    : s.to_do_failed,
          );
          context.read<CreateAppraisalCubit>().resetUpdateStatus();
        }
      },
      child: BlocBuilder<CreateAppraisalCubit, CreateAppraisalState>(
        builder: (context, state) {
          final isDetail = state.isDetail == true;
          final isCreate = !isDetail && state.isEdit != true;
          final isLeaderReview = !isCreate && state.currentTabIndex == 1;

          if (!_didHydrateDetail && state.detailEvaluation != null) {
            _hydrateDetail(state);
          }

          if (isCreate && !_didInitializeCreate) {
            _initializeCreateDefaults();
            _fillTotalByStep(state, isLeaderReview: false);
          }

          final actionText =
              _currentStep < 3
                  ? s.appraisal_next
                  : state.isEdit == true
                  ? s.save
                  : s.confirm;

          return Scaffold(
            appBar: MyAppBar(
              titleAppbar: s.appraisal_form_title,
              haveBackButton: true,
              haveActionButton: true,
              iconPathAsset: AppAssets.icNotificationBell,
              actionCallBack: () {},
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (!isCreate) ...[
                      _buildTabBar(s),
                      const SizedBox(height: 8),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            isLeaderReview
                                ? _buildStepperLeaderReview()
                                : _buildStepper(),
                            const SizedBox(height: 8),
                            _buildHeaderByStep(s),
                            _buildStepContent(isDetail, state, isLeaderReview),
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
                                mainText: s.appraisal_back,
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
                                enable:
                                    state.updateStatus != LoadStatus.LOADING,
                                isLoading:
                                    state.isEdit == true &&
                                    _currentStep == 3 &&
                                    state.updateStatus == LoadStatus.LOADING,
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
          );
        },
      ),
    );
  }

  Widget _buildTabBar(S s) {
    final tabs = [
      MasterDataItem(text: s.appraisal_tab_form, id: 0),
      MasterDataItem(text: s.appraisal_tab_direct_manager, id: 1),
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
      child: BlocBuilder<CreateAppraisalCubit, CreateAppraisalState>(
        buildWhen: (prev, cur) => prev.currentTabIndex != cur.currentTabIndex,
        builder: (context, state) {
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
                    onTap: () {
                      final cubit = context.read<CreateAppraisalCubit>();
                      if (index != cubit.state.currentTabIndex) {
                        cubit.onChangeTab(index);
                        cubit.onChangeCurrentTabItem(item);
                        setState(() {
                          _fillTotalByStep(
                            cubit.state,
                            isLeaderReview: index == 1,
                          );
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFF3F3F5) : Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        item.text ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
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
        },
      ),
    );
  }
}
