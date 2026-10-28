import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/evaluation_entity.dart';
import 'package:pm_app/app/data/models/entities/experience_id_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/entities/responsive_id_entity.dart';
import 'package:pm_app/app/data/models/entities/skill_id_entity.dart';
import 'package:pm_app/app/data/models/entities/suggest_id_entity.dart';
import 'package:pm_app/app/data/models/entities/task_line_id_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/detail_apprasial_cubit.dart';
import 'package:pm_app/app/features/ui/appraisal_form/widgets/hr_dialog.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/steps/appraisal_step_experience_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/steps/appraisal_step_opinion_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/steps/appraisal_step_responsibility_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/steps/appraisal_step_result_work_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/steps/appraisal_step_skill_v2.dart';
import 'package:pm_app/app/features/ui_v2/appraisal_form/widgets/hr_dialog_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

/// Orchestrator luồng đánh giá (appraisal) — phiên bản giao diện tối (v2).
/// Chỉ đổi trình bày (chrome/màu sắc/kiểu chữ): toàn bộ state machine, tính
/// điểm, validate, payload gửi lên cubit và luồng điều hướng được copy y hệt
/// [ApprasisalProgressPage] gốc — không đổi nghiệp vụ.
class ApprasisalProgressPageV2 extends StatefulWidget {
  const ApprasisalProgressPageV2({super.key});

  @override
  State<ApprasisalProgressPageV2> createState() =>
      _ApprasisalProgressPageV2State();
}

class _ApprasisalProgressPageV2State extends State<ApprasisalProgressPageV2> {
  static const int _totalSteps = 5;
  static const int _lastStepIndex = _totalSteps - 1;

  int _currentStep = 0;
  bool _didHydrateDetail = false;
  bool _didInitializeCreate = false;
  bool _showCoefError = false;
  bool _isHrAssessFlow = false;
  bool _isManagerAssessFlow = false;

  bool get _showLegacyCoefError => false;
  static const List<double> _responseCoefficients = [2, 2, 1.5, 2, 0.5];
  static const List<double> _skillCoefficients = [1, 1, 0.5, 0.5, 1];

  List<TaskLineIdEntity> _taskItems = [];
  List<ResponsiveIdEntity> _responseItems = [];
  List<SkillIdEntity> _skillItems = [];
  List<ExperienceIdEntity> _experienceItems = [];
  List<SuggestIdEntity> _suggestItems = [];

  final List<TextEditingController> _taskEvidenceControllers = [];
  final List<TextEditingController> _taskNameControllers = [];
  final List<TextEditingController> _taskRateControllers = [];
  final List<TextEditingController> _leaderTaskEvidenceControllers = [];
  final List<TextEditingController> _responseEvidenceControllers = [];
  final List<TextEditingController> _leaderResponseEvidenceControllers = [];
  final List<TextEditingController> _skillEvidenceControllers = [];
  final List<TextEditingController> _leaderSkillEvidenceControllers = [];
  final List<TextEditingController> _experienceProjectControllers = [];
  final List<TextEditingController> _experienceFromDateControllers = [];
  final List<TextEditingController> _experienceToDateControllers = [];
  final List<TextEditingController> _experienceTechniqueControllers = [];
  final List<TextEditingController> _experienceNumberPeopleControllers = [];
  final List<TextEditingController> _experienceNoteControllers = [];
  final List<TextEditingController> _suggestControllers = [];
  final Map<int, bool> _taskHrChecked = {};
  final Map<int, bool> _responseHrChecked = {};
  final Map<int, bool> _skillHrChecked = {};
  final Map<int, bool> _suggestHrChecked = {};
  final Map<int, String> _taskHrNotes = {};
  final Map<int, String> _responseHrNotes = {};
  final Map<int, String> _skillHrNotes = {};
  final Map<int, String> _suggestHrNotes = {};

  final TextEditingController _coefCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CreateAppraisalCubit>();
      cubit.getListJob();
    });
  }

  int _totalTaskRate(List<TaskLineIdEntity> tasks) {
    return tasks.fold<int>(0, (sum, task) => sum + (task.rate ?? 0));
  }

  bool _hasValidTaskRateTotal() => _totalTaskRate(_taskItems) == 100;

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool get _isHrReviewer {
    final profile = GlobalData.instance.userProfile;
    final jobTitle = profile?.jobTitle?.toLowerCase() ?? '';
    final departmentName = profile?.department?.name?.toLowerCase() ?? '';

    return jobTitle.contains('hr') ||
        jobTitle.contains('nhân sự') ||
        jobTitle.contains('hành chính nhân sự') ||
        departmentName.contains('nhân sự') ||
        departmentName.contains('hành chính nhân sự');
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

  String _displayExperienceDate(String? raw) {
    return AppDateUtils.formatFlexibleDateForDisplay(
      raw,
      datePattern: 'MM/yyyy',
    );
  }

  int _totalTaskRateExcept(int excludedIndex) {
    var total = 0;
    for (int index = 0; index < _taskItems.length; index++) {
      if (index == excludedIndex) continue;
      total += _taskItems[index].rate ?? 0;
    }
    return total;
  }

  void _syncTaskRateController(int index, String text) {
    if (index < 0 || index >= _taskRateControllers.length) return;

    final controller = _taskRateControllers[index];
    if (controller.text == text) return;

    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _refreshHeaderTotals() {
    final state = context.read<CreateAppraisalCubit>().state;
    final isCreate = state.isDetail != true && state.isEdit != true;
    final isLeaderReview = !isCreate && state.currentTabIndex == 1;
    final totalRate = _totalTaskRate(_taskItems);
    _coefCtrl.text = (totalRate > 100 ? 100 : totalRate).toString();
    _showCoefError = _currentStep == 0 && !isLeaderReview && totalRate != 100;
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

  List<SuggestIdEntity> _normalizeSuggestItems(List<SuggestIdEntity> items) {
    final normalized = [for (final item in items) item.copyWith()];

    final hasDg01 = normalized.any(
      (item) => item.code?.trim().toUpperCase() == 'DG01',
    );
    final hasDg02 = normalized.any(
      (item) => item.code?.trim().toUpperCase() == 'DG02',
    );

    if (!hasDg01) {
      normalized.insert(
        0,
        SuggestIdEntity(
          code: 'DG01',
          name: 'Ý kiến - Đề xuất của người được đánh giá',
        ),
      );
    }

    if (!hasDg02) {
      normalized.add(SuggestIdEntity(code: 'DG02', name: 'Cấp trên đánh giá'));
    }

    return normalized;
  }

  void _hydrateDetail(CreateAppraisalState state) {
    final detail = state.detailEvaluation;
    if (detail == null) return;
    final shouldMirrorLeaderReview = _shouldMirrorLeaderReview(state);

    _taskItems = [
      for (final item in detail.taskLineIds ?? <TaskLineIdEntity>[])
        shouldMirrorLeaderReview
            ? _copyTaskSelfReviewToLeaderReview(item)
            : item.copyWith(),
    ];
    _responseItems = [
      for (final item in detail.responseIds ?? <ResponsiveIdEntity>[])
        shouldMirrorLeaderReview
            ? _copyResponseSelfReviewToLeaderReview(item)
            : item.copyWith(),
    ];
    _skillItems = [
      for (final item in detail.skillIds ?? <SkillIdEntity>[])
        shouldMirrorLeaderReview
            ? _copySkillSelfReviewToLeaderReview(item)
            : item.copyWith(),
    ];
    _experienceItems = [
      for (final item in detail.experienceIds ?? <ExperienceIdEntity>[])
        item.copyWith(),
    ];
    _suggestItems = _normalizeSuggestItems(
      detail.suggestIds ?? <SuggestIdEntity>[],
    );

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
      _experienceProjectControllers,
      _experienceItems.map((item) => item.name ?? '').toList(),
    );
    _replaceControllers(
      _experienceFromDateControllers,
      _experienceItems
          .map((item) => _displayExperienceDate(item.dateFrom))
          .toList(),
    );
    _replaceControllers(
      _experienceToDateControllers,
      _experienceItems
          .map((item) => _displayExperienceDate(item.dateTo))
          .toList(),
    );
    _replaceControllers(
      _experienceTechniqueControllers,
      _experienceItems.map((item) => item.techniqueName ?? '').toList(),
    );
    _replaceControllers(
      _experienceNumberPeopleControllers,
      _experienceItems.map((item) => item.numberPeople ?? '').toList(),
    );
    _replaceControllers(
      _experienceNoteControllers,
      _experienceItems.map((item) => item.note ?? '').toList(),
    );
    _replaceControllers(
      _suggestControllers,
      _suggestItems.map((item) => item.note ?? '').toList(),
    );

    _coefCtrl.text = _totalTaskRate(_taskItems).toString();
    _fillTotalByStep(state, isLeaderReview: state.currentTabIndex == 1);
    _didHydrateDetail = true;
  }

  bool _shouldMirrorLeaderReview(CreateAppraisalState state) {
    return state.isEdit == true &&
        state.isManagerAssess != true &&
        state.isHRReview != true &&
        state.detailEvaluation?.state?.trim() == 'draft';
  }

  TaskLineIdEntity _copyTaskSelfReviewToLeaderReview(TaskLineIdEntity item) {
    return TaskLineIdEntity(
      id: item.id,
      name: item.name,
      jiraKey: item.jiraKey,
      rate: item.rate,
      volume: item.volume,
      quality: item.quality,
      progress: item.progress,
      note: item.note,
      parentVolume: item.volume,
      parentQuality: item.quality,
      parentProgress: item.progress,
      parentNote: item.parentNote,
      weight: item.weight,
      totalScore: item.totalScore,
      parentTotalScore: item.parentTotalScore,
    );
  }

  ResponsiveIdEntity _copyResponseSelfReviewToLeaderReview(
    ResponsiveIdEntity item,
  ) {
    return ResponsiveIdEntity(
      id: item.id,
      code: item.code,
      name: item.name,
      note: item.note,
      ratePoint: item.ratePoint,
      parentRatePoint: item.ratePoint,
      parentNote: item.parentNote,
      isChecked: item.isChecked,
    );
  }

  SkillIdEntity _copySkillSelfReviewToLeaderReview(SkillIdEntity item) {
    return SkillIdEntity(
      id: item.id,
      code: item.code,
      name: item.name,
      note: item.note,
      ratePoint: item.ratePoint,
      parentRatePoint: item.ratePoint,
      parentNote: item.parentNote,
    );
  }

  void _initializeCreateDefaults() {
    _taskItems = [TaskLineIdEntity()];
    _experienceItems = [ExperienceIdEntity()];
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
    _suggestItems = _normalizeSuggestItems(const []);
    /*

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

    */
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
    _replaceControllers(_experienceFromDateControllers, const ['']);
    _replaceControllers(_experienceToDateControllers, const ['']);
    _replaceControllers(_experienceProjectControllers, const ['']);
    _replaceControllers(_experienceTechniqueControllers, const ['']);
    _replaceControllers(_experienceNumberPeopleControllers, const ['']);
    _replaceControllers(_experienceNoteControllers, const ['']);
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

  bool _isSelfReviewLocked(CreateAppraisalState state, bool isLeaderReview) {
    if (state.isDetail == true || isLeaderReview) return false;

    final evaluationState = state.detailEvaluation?.state?.trim();
    return evaluationState == 'director_confirm' ||
        evaluationState == 'approved';
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
          updated = current.copyWith(
            volume: value,
            parentVolume:
                _shouldMirrorLeaderReview(
                      context.read<CreateAppraisalCubit>().state,
                    )
                    ? value
                    : null,
          );
          break;
        case 1:
          updated = current.copyWith(
            quality: value,
            parentQuality:
                _shouldMirrorLeaderReview(
                      context.read<CreateAppraisalCubit>().state,
                    )
                    ? value
                    : null,
          );
          break;
        default:
          updated = current.copyWith(
            progress: value,
            parentProgress:
                _shouldMirrorLeaderReview(
                      context.read<CreateAppraisalCubit>().state,
                    )
                    ? value
                    : null,
          );
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

  TaskLineIdEntity _taskWithRate(TaskLineIdEntity current, int? rate) {
    return TaskLineIdEntity(
      id: current.id,
      name: current.name,
      jiraKey: current.jiraKey,
      rate: rate,
      volume: current.volume,
      quality: current.quality,
      progress: current.progress,
      note: current.note,
      parentVolume: current.parentVolume,
      parentQuality: current.parentQuality,
      parentProgress: current.parentProgress,
      parentNote: current.parentNote,
      weight: current.weight,
      totalScore: current.totalScore,
      parentTotalScore: current.parentTotalScore,
    );
  }

  void _updateTaskRate(int index, String value) {
    final trimmed = value.trim();
    final current = _taskItems[index];

    if (trimmed.isEmpty) {
      _syncTaskRateController(index, '');
      setState(() {
        _taskItems[index] = _taskWithRate(current, null);
        _refreshHeaderTotals();
      });
      return;
    }

    final parsed = int.tryParse(trimmed) ?? 0;
    final normalized = parsed < 0 ? 0 : parsed;
    final maxAllowed = 100 - _totalTaskRateExcept(index);
    final clampedRate = normalized > maxAllowed ? maxAllowed : normalized;

    _syncTaskRateController(index, clampedRate.toString());

    setState(() {
      _taskItems[index] = _taskWithRate(current, clampedRate);
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
              : current.copyWith(
                ratePoint: value,
                parentRatePoint:
                    _shouldMirrorLeaderReview(
                          context.read<CreateAppraisalCubit>().state,
                        )
                        ? value
                        : null,
              );
      _refreshHeaderTotals();
    });
  }

  void _updateSkillRating(bool isLeaderReview, int index, int value) {
    final current = _skillItems[index];
    setState(() {
      _skillItems[index] =
          isLeaderReview
              ? current.copyWith(parentRatePoint: value)
              : current.copyWith(
                ratePoint: value,
                parentRatePoint:
                    _shouldMirrorLeaderReview(
                          context.read<CreateAppraisalCubit>().state,
                        )
                        ? value
                        : null,
              );
      _refreshHeaderTotals();
    });
  }

  void _updateTaskEvidence(bool isLeaderReview, int index, String value) {
    final current = _taskItems[index];
    setState(() {
      _taskItems[index] =
          isLeaderReview
              ? current.copyWith(parentNote: value)
              : current.copyWith(note: value);
    });
  }

  void _updateResponseEvidence(bool isLeaderReview, int index, String value) {
    final current = _responseItems[index];
    setState(() {
      _responseItems[index] =
          isLeaderReview
              ? current.copyWith(parentNote: value)
              : current.copyWith(note: value);
    });
  }

  void _updateSkillEvidence(bool isLeaderReview, int index, String value) {
    final current = _skillItems[index];
    setState(() {
      _skillItems[index] =
          isLeaderReview
              ? current.copyWith(parentNote: value)
              : current.copyWith(note: value);
    });
  }

  void _updateExperienceProject(int index, String value) {
    final current = _experienceItems[index];
    setState(() {
      _experienceItems[index] = current.copyWith(name: value);
    });
  }

  void _updateExperienceTechnique(int index, String value) {
    final current = _experienceItems[index];
    setState(() {
      _experienceItems[index] = current.copyWith(techniqueName: value);
    });
  }

  void _updateExperienceNumberPeople(int index, String value) {
    final current = _experienceItems[index];
    setState(() {
      _experienceItems[index] = current.copyWith(numberPeople: value);
    });
  }

  void _updateExperienceNote(int index, String value) {
    final current = _experienceItems[index];
    setState(() {
      _experienceItems[index] = current.copyWith(note: value);
    });
  }

  void _updateSuggestNote(int index, String value) {
    final current = _suggestItems[index];
    setState(() {
      _suggestItems[index] = current.copyWith(note: value);
    });
  }

  void _updateExperiencePosition(int index, int? positionId) {
    final current = _experienceItems[index];
    setState(() {
      _experienceItems[index] = current.copyWith(positionId: positionId);
    });
  }

  void _updateExperienceDateFrom(int index, DateTime value) {
    final current = _experienceItems[index];
    _experienceFromDateControllers[index].text = DateFormat(
      'MM/yyyy',
    ).format(value);
    setState(() {
      _experienceItems[index] = current.copyWith(
        dateFrom: DateFormat('MM/yyyy').format(value),
      );
    });
  }

  void _updateExperienceDateTo(int index, DateTime value) {
    final current = _experienceItems[index];
    _experienceToDateControllers[index].text = DateFormat(
      'MM/yyyy',
    ).format(value);
    setState(() {
      _experienceItems[index] = current.copyWith(
        dateTo: DateFormat('MM/yyyy').format(value),
      );
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

  void _addExperienceCriteria() {
    setState(() {
      _experienceItems = [..._experienceItems, ExperienceIdEntity()];
      _experienceProjectControllers.add(TextEditingController());
      _experienceFromDateControllers.add(TextEditingController());
      _experienceToDateControllers.add(TextEditingController());
      _experienceTechniqueControllers.add(TextEditingController());
      _experienceNumberPeopleControllers.add(TextEditingController());
      _experienceNoteControllers.add(TextEditingController());
    });
  }

  void _removeExperienceCriteria(int index) {
    if (_experienceItems.length <= 1) return;

    setState(() {
      _experienceItems.removeAt(index);
      _experienceProjectControllers.removeAt(index).dispose();
      _experienceFromDateControllers.removeAt(index).dispose();
      _experienceToDateControllers.removeAt(index).dispose();
      _experienceTechniqueControllers.removeAt(index).dispose();
      _experienceNumberPeopleControllers.removeAt(index).dispose();
      _experienceNoteControllers.removeAt(index).dispose();
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

    final experienceIds = List.generate(_experienceItems.length, (index) {
      final item = _experienceItems[index];
      return <String, dynamic>{
        "name": _nullableTextAt(_experienceProjectControllers, index),
        "position_id": item.positionId,
        "date_from": item.dateFrom,
        "date_to": item.dateTo,
        "technique_name": _nullableTextAt(
          _experienceTechniqueControllers,
          index,
        ),
        "number_people": _nullableTextAt(
          _experienceNumberPeopleControllers,
          index,
        ),
        "note": _nullableTextAt(_experienceNoteControllers, index),
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
      "experience_ids": experienceIds,
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

    final experienceIds = List.generate(_experienceItems.length, (index) {
      final item = _experienceItems[index];
      return item.copyWith(
        name: _nullableTextAt(_experienceProjectControllers, index),
        techniqueName: _nullableTextAt(_experienceTechniqueControllers, index),
        numberPeople: _nullableTextAt(
          _experienceNumberPeopleControllers,
          index,
        ),
        note: _nullableTextAt(_experienceNoteControllers, index),
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
      experienceIds: experienceIds,
      suggestIds: suggestIds,
    );
  }

  void _submitUpdate(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    final payload = _buildUpdatePayload(state);
    if (id == 0 || payload == null) return;
    context.read<CreateAppraisalCubit>().updateEvaluation(id, payload);
  }

  bool _isTaskAssessmentMatched(TaskLineIdEntity item) {
    return _toInt(item.parentVolume) == _toInt(item.volume) &&
        _toInt(item.parentQuality) == _toInt(item.quality) &&
        _toInt(item.parentProgress) == _toInt(item.progress);
  }

  bool _isResponseAssessmentMatched(ResponsiveIdEntity item) {
    return _toInt(item.parentRatePoint) == _toInt(item.ratePoint);
  }

  bool _isSkillAssessmentMatched(SkillIdEntity item) {
    return _toInt(item.parentRatePoint) == _toInt(item.ratePoint);
  }

  Map<String, dynamic>? _buildManagerAssessPayload(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    if (id == 0) return null;

    final taskLineIds = <Map<String, dynamic>>[];
    for (int index = 0; index < _taskItems.length; index++) {
      final item = _taskItems[index];
      if (item.id == null) continue;

      taskLineIds.add(<String, dynamic>{
        "id": item.id,
        "parent_volume": _toInt(item.parentVolume),
        "parent_quality": _toInt(item.parentQuality),
        "parent_progress": _toInt(item.parentProgress),
        "parent_note": _nullableTextAt(_leaderTaskEvidenceControllers, index),
        "is_checked": _isTaskAssessmentMatched(item),
      });
    }

    final responseIds = <Map<String, dynamic>>[];
    for (int index = 0; index < _responseItems.length; index++) {
      final item = _responseItems[index];
      if (item.id == null) continue;

      responseIds.add(<String, dynamic>{
        "id": item.id,
        "parent_rate_point": _toInt(item.parentRatePoint),
        "parent_note": _nullableTextAt(
          _leaderResponseEvidenceControllers,
          index,
        ),
        "is_checked": _isResponseAssessmentMatched(item),
      });
    }

    final skillIds = <Map<String, dynamic>>[];
    for (int index = 0; index < _skillItems.length; index++) {
      final item = _skillItems[index];
      if (item.id == null) continue;

      skillIds.add(<String, dynamic>{
        "id": item.id,
        "parent_rate_point": _toInt(item.parentRatePoint),
        "parent_note": _nullableTextAt(_leaderSkillEvidenceControllers, index),
        "is_checked": _isSkillAssessmentMatched(item),
      });
    }

    final suggestIds = <Map<String, dynamic>>[];
    for (int index = 0; index < _suggestItems.length; index++) {
      final item = _suggestItems[index];
      final code = item.code?.trim().toUpperCase();
      if (code != 'DG02' || item.id == null) continue;

      suggestIds.add(<String, dynamic>{
        "id": item.id,
        "note": _nullableTextAt(_suggestControllers, index),
        "is_checked": true,
      });
    }

    return <String, dynamic>{
      "task_line_ids": taskLineIds,
      "response_ids": responseIds,
      "skill_ids": skillIds,
      "suggest_ids": suggestIds,
    };
  }

  bool _checkedValueAt(Map<int, bool> values, int index) {
    return values[index] ?? true;
  }

  String _hrNoteAt(Map<int, String> values, int index) {
    return values[index] ?? '';
  }

  String _hrStatusTextAt(Map<int, bool> values, int index) {
    if (!values.containsKey(index)) return '';
    return _checkedValueAt(values, index) ? 'Đồng ý' : 'Từ chối';
  }

  bool _hasText(String? value) => value?.trim().isNotEmpty == true;

  bool _isTaskLineValid(int index, {required bool isLeaderReview}) {
    final item = _taskItems[index];
    final hasName =
        _hasText(item.name) || _hasText(_textAt(_taskNameControllers, index));
    final hasRate = (item.rate ?? 0) > 0;
    final hasEvidence = _hasText(
      _textAt(_taskControllersForTab(isLeaderReview), index),
    );

    final volume = _toInt(isLeaderReview ? item.parentVolume : item.volume);
    final quality = _toInt(isLeaderReview ? item.parentQuality : item.quality);
    final progress = _toInt(
      isLeaderReview ? item.parentProgress : item.progress,
    );

    return hasName &&
        hasRate &&
        hasEvidence &&
        volume > 0 &&
        quality > 0 &&
        progress > 0;
  }

  bool _isResponseLineValid(int index, {required bool isLeaderReview}) {
    final item = _responseItems[index];
    final rate = _toInt(isLeaderReview ? item.parentRatePoint : item.ratePoint);
    final hasEvidence = _hasText(
      _textAt(_responseControllersForTab(isLeaderReview), index),
    );
    return rate > 0 && hasEvidence;
  }

  bool _isSkillLineValid(int index, {required bool isLeaderReview}) {
    final item = _skillItems[index];
    final rate = _toInt(isLeaderReview ? item.parentRatePoint : item.ratePoint);
    final hasEvidence = _hasText(
      _textAt(_skillControllersForTab(isLeaderReview), index),
    );
    return rate > 0 && hasEvidence;
  }

  bool _isExperienceLineValid(int index) {
    final item = _experienceItems[index];
    return _hasText(_textAt(_experienceProjectControllers, index)) &&
        item.positionId != null &&
        _hasText(item.dateFrom) &&
        _hasText(item.dateTo) &&
        _hasText(_textAt(_experienceTechniqueControllers, index)) &&
        _hasText(_textAt(_experienceNumberPeopleControllers, index)) &&
        _hasText(_textAt(_experienceNoteControllers, index));
  }

  List<int> _visibleSuggestIndexes({
    required bool isLeaderReview,
    required bool isHrReviewFlow,
  }) {
    final filtered = <int>[];

    for (int index = 0; index < _suggestItems.length; index++) {
      final code = _suggestItems[index].code?.trim().toUpperCase();
      if (isHrReviewFlow) {
        if (code == 'DG03') {
          filtered.add(index);
        }
        continue;
      }

      if (isLeaderReview) {
        if (code == 'DG02') {
          filtered.add(index);
        }
        continue;
      }

      if (code != 'DG02' && code != 'DG03') {
        filtered.add(index);
      }
    }

    return filtered.isNotEmpty
        ? filtered
        : List<int>.generate(_suggestItems.length, (index) => index);
  }

  bool _isSuggestLineValid(int index) {
    return _hasText(_textAt(_suggestControllers, index));
  }

  bool _canProceed({
    required bool isDetail,
    required bool isLeaderReview,
    required bool isHrReviewFlow,
    required bool isSelfReviewLocked,
  }) {
    if (isDetail || isSelfReviewLocked || isHrReviewFlow) {
      return true;
    }

    switch (_currentStep) {
      case 0:
        return _taskItems.length >= 3 &&
            _hasValidTaskRateTotal() &&
            _taskItems.isNotEmpty &&
            List<bool>.generate(
              _taskItems.length,
              (index) =>
                  _isTaskLineValid(index, isLeaderReview: isLeaderReview),
            ).every((value) => value);
      case 1:
        return _responseItems.isNotEmpty &&
            List<bool>.generate(
              _responseItems.length,
              (index) =>
                  _isResponseLineValid(index, isLeaderReview: isLeaderReview),
            ).every((value) => value);
      case 2:
        return _skillItems.isNotEmpty &&
            List<bool>.generate(
              _skillItems.length,
              (index) =>
                  _isSkillLineValid(index, isLeaderReview: isLeaderReview),
            ).every((value) => value);
      case 3:
        return _experienceItems.isNotEmpty &&
            List<bool>.generate(
              _experienceItems.length,
              _isExperienceLineValid,
            ).every((value) => value);
      case 4:
        final visibleIndexes = _visibleSuggestIndexes(
          isLeaderReview: isLeaderReview,
          isHrReviewFlow: isHrReviewFlow,
        );
        return visibleIndexes.isNotEmpty &&
            visibleIndexes.map(_isSuggestLineValid).every((value) => value);
      default:
        return true;
    }
  }

  Future<HrDialogResult?> _showHrItemDialog(String? initialNote) {
    return HrDialogV2.show(context, initialNote: initialNote);
  }

  Future<void> _onHrTaskTap(int index) async {
    final initialNote = _taskHrNotes[index] ?? _taskItems[index].parentNote;
    final result = await _showHrItemDialog(initialNote);
    if (result == null || !mounted) return;

    setState(() {
      _taskHrNotes[index] = result.note;
      _taskHrChecked[index] = result.isApproved;
    });
  }

  Future<void> _onHrResponseTap(int index) async {
    final initialNote =
        _responseHrNotes[index] ?? _responseItems[index].parentNote;
    final result = await _showHrItemDialog(initialNote);
    if (result == null || !mounted) return;

    setState(() {
      _responseHrNotes[index] = result.note;
      _responseHrChecked[index] = result.isApproved;
    });
  }

  Future<void> _onHrSkillTap(int index) async {
    final initialNote = _skillHrNotes[index] ?? _skillItems[index].parentNote;
    final result = await _showHrItemDialog(initialNote);
    if (result == null || !mounted) return;

    setState(() {
      _skillHrNotes[index] = result.note;
      _skillHrChecked[index] = result.isApproved;
    });
  }

  Future<void> _onHrSuggestTap(int index) async {
    final initialNote = _suggestHrNotes[index] ?? _suggestItems[index].note;
    final result = await _showHrItemDialog(initialNote);
    if (result == null || !mounted) return;

    setState(() {
      _suggestHrNotes[index] = result.note;
      _suggestHrChecked[index] = result.isApproved;
    });
  }

  Map<String, dynamic>? _buildHrAssessPayload(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    if (id == 0) return null;

    final taskLineIds =
        _taskItems.map((item) => item.id).contains(null)
            ? <Map<String, dynamic>>[]
            : List.generate(_taskItems.length, (index) {
              final item = _taskItems[index];
              return <String, dynamic>{
                "id": item.id,
                "parent_volume": _toInt(item.parentVolume),
                "parent_quality": _toInt(item.parentQuality),
                "parent_progress": _toInt(item.parentProgress),
                "parent_note": _hrNoteAt(_taskHrNotes, index),
                "is_checked": _checkedValueAt(_taskHrChecked, index),
              };
            });

    final responseIds =
        _responseItems.map((item) => item.id).contains(null)
            ? <Map<String, dynamic>>[]
            : List.generate(_responseItems.length, (index) {
              final item = _responseItems[index];
              return <String, dynamic>{
                "id": item.id,
                "parent_rate_point": _toInt(item.parentRatePoint),
                "parent_note": _hrNoteAt(_responseHrNotes, index),
                "is_checked": _checkedValueAt(_responseHrChecked, index),
              };
            });

    final skillIds =
        _skillItems.map((item) => item.id).contains(null)
            ? <Map<String, dynamic>>[]
            : List.generate(_skillItems.length, (index) {
              final item = _skillItems[index];
              return <String, dynamic>{
                "id": item.id,
                "parent_rate_point": _toInt(item.parentRatePoint),
                "parent_note": _hrNoteAt(_skillHrNotes, index),
                "is_checked": _checkedValueAt(_skillHrChecked, index),
              };
            });

    final suggestIds =
        _suggestItems.map((item) => item.id).contains(null)
            ? <Map<String, dynamic>>[]
            : List.generate(_suggestItems.length, (index) {
              final item = _suggestItems[index];
              return <String, dynamic>{
                "id": item.id,
                "note": _hrNoteAt(_suggestHrNotes, index),
                "is_checked": _checkedValueAt(_suggestHrChecked, index),
              };
            });

    return <String, dynamic>{
      "task_line_ids": taskLineIds,
      "response_ids": responseIds,
      "skill_ids": skillIds,
      "suggest_ids": suggestIds,
    };
  }

  void _submitHrAssessment(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    final payload = _buildHrAssessPayload(state);
    if (id == 0 || payload == null) return;

    _isHrAssessFlow = true;
    context.read<CreateAppraisalCubit>().assessEvaluation(id, payload);
  }

  void _submitManagerAssessment(CreateAppraisalState state) {
    final id = state.detailEvaluation?.id ?? 0;
    final payload = _buildManagerAssessPayload(state);
    if (id == 0 || payload == null) return;

    _isManagerAssessFlow = true;
    context.read<CreateAppraisalCubit>().assessEvaluation(id, payload);
  }

  void _showSaveDialog(CreateAppraisalState state) {
    final isManagerAssessFlow = state.isManagerAssess == true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CustomDialog(
            title: 'Xác nhận',
            content: 'Bạn có chắc muốn lưu phiếu đánh giá này không?',
            confirmText: 'Đồng ý',
            cancelText: 'Hủy',
            onConfirm: () {
              Navigator.pop(context);
              if (isManagerAssessFlow) {
                _submitManagerAssessment(state);
                return;
              }
              _submitUpdate(state);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
    );
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
    final isManagerAssessFlow = state.isManagerAssess == true;
    final isHrReviewFlow =
        !isManagerAssessFlow &&
        (state.isHRReview == true ||
            (state.isEdit == true &&
                _isHrReviewer &&
                state.currentTabIndex == 1));
    final isLeaderReview =
        state.currentTabIndex == 1 &&
        (isManagerAssessFlow || (!isHrReviewFlow && !isCreate));
    final isSelfReviewLocked = _isSelfReviewLocked(state, isLeaderReview);
    final canProceed = _canProceed(
      isDetail: isDetail,
      isLeaderReview: isLeaderReview,
      isHrReviewFlow: isHrReviewFlow,
      isSelfReviewLocked: isSelfReviewLocked,
    );

    if (!canProceed) {
      setState(() {
        _showCoefError = _currentStep == 0 && !_hasValidTaskRateTotal();
      });
      return;
    }

    if (!isDetail &&
        !isSelfReviewLocked &&
        !isLeaderReview &&
        _currentStep == 0 &&
        !_hasValidTaskRateTotal()) {
      setState(() {
        _showCoefError = true;
      });
      return;
    }

    if (_currentStep < _lastStepIndex) {
      setState(() {
        _currentStep++;
        _showCoefError = false;
        _fillTotalByStep(state, isLeaderReview: state.currentTabIndex == 1);
      });
      return;
    }

    if (isHrReviewFlow) {
      _submitHrAssessment(state);
      return;
    }

    if (isManagerAssessFlow) {
      _showSaveDialog(state);
      return;
    }

    if (state.isEdit == true && !isSelfReviewLocked) {
      _showSaveDialog(state);
      return;
    }

    if (state.isDetail == true || isSelfReviewLocked) {
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
    const lineWidth = 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
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
                          ? AppTokensV2.accent
                          : AppTokensV2.surfaceStrong,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTokensV2.accent, width: 2),
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
                              : AppTokensV2.accent,
                    ),
                  ),
                ),
              ),
              if (index < _totalSteps - 1)
                Container(
                  width: lineWidth,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color:
                      isCompleted
                          ? AppTokensV2.accent
                          : AppTokensV2.accent.withValues(alpha: 0.25),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepperLeaderReview() {
    const circleSize = 26.0;
    const lineWidth = 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
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
                          ? AppTokensV2.accent2
                          : AppTokensV2.surfaceStrong,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTokensV2.accent2, width: 2),
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
                              : AppTokensV2.accent2,
                    ),
                  ),
                ),
              ),
              if (index < _totalSteps - 1)
                Container(
                  width: lineWidth,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color:
                      isCompleted
                          ? AppTokensV2.accent2
                          : AppTokensV2.accent2.withValues(alpha: 0.25),
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
                  v2Style: true,
                  title: '',
                  hintText: s.appraisal_coefficient,
                  controller: _coefCtrl,
                  readOnly: true,
                  isRequiredField: false,
                  fillBgColor: AppTokensV2.surfaceStrong,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTokensV2.fg,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 16,
                  child:
                      _showCoefError
                          ? Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              'Tổng hệ số phải bằng 100%',
                              style: TextStyle(
                                color: AppTokensV2.danger,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                if (_showLegacyCoefError && _showCoefError) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Tổng hệ số phải bằng 100%',
                      style: TextStyle(
                        color: AppTokensV2.danger,
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
              v2Style: true,
              title: '',
              hintText: s.appraisal_total_score,
              controller: _totalCtrl,
              readOnly: true,
              isRequiredField: false,
              fillBgColor: AppTokensV2.surfaceStrong,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTokensV2.fg,
              ),
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
        v2Style: true,
        title: '',
        hintText: s.appraisal_total_score,
        controller: _totalCtrl,
        readOnly: true,
        isRequiredField: false,
        fillBgColor: AppTokensV2.surfaceStrong,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppTokensV2.fg,
        ),
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
    final isCreate = state.isDetail != true && state.isEdit != true;
    final isManagerAssessFlow = state.isManagerAssess == true;
    final isHrReviewFlow =
        !isManagerAssessFlow &&
        (state.isHRReview == true ||
            (state.isEdit == true &&
                _isHrReviewer &&
                state.currentTabIndex == 1));
    final isSelfReviewLocked = _isSelfReviewLocked(state, isLeaderReview);
    final readOnly = isDetail || isSelfReviewLocked || isHrReviewFlow;

    if (_currentStep == 0) {
      return AppraisalStepResultWorkV2(
        isLeaderReview: isLeaderReview,
        listTask: _taskItems,
        nameControllers: _taskNameControllers,
        rateControllers: _taskRateControllers,
        evidenceControllers: _taskControllersForTab(isLeaderReview),
        readOnly: readOnly,
        onAddCriteria: (!readOnly && !isLeaderReview) ? _addTaskCriteria : null,
        onNameChanged: _updateTaskName,
        onTaskRateChanged: _updateTaskRate,
        onEvidenceChanged:
            (index, value) => _updateTaskEvidence(isLeaderReview, index, value),
        onRate:
            (taskIndex, ratingIndex, value) => _updateTaskRating(
              isLeaderReview,
              taskIndex,
              ratingIndex,
              value,
            ),
        onItemTap: isHrReviewFlow ? _onHrTaskTap : null,
        hrNoteText:
            isHrReviewFlow ? (index) => _hrNoteAt(_taskHrNotes, index) : null,
        hrStatusText:
            isHrReviewFlow
                ? (index) => _hrStatusTextAt(_taskHrChecked, index)
                : null,
        autoShowHelp: isCreate,
      );
    }

    if (_currentStep == 1) {
      return AppraisalStepResponsibilityV2(
        responses: _responseItems,
        evidences: _responseControllersForTab(isLeaderReview),
        readOnly: readOnly,
        onRate: (index, value) {
          _updateResponseRating(isLeaderReview, index, value);
        },
        onEvidenceChanged:
            (index, value) =>
                _updateResponseEvidence(isLeaderReview, index, value),
        isLeaderReview: isLeaderReview,
        onItemTap: isHrReviewFlow ? _onHrResponseTap : null,
        hrNoteText:
            isHrReviewFlow
                ? (index) => _hrNoteAt(_responseHrNotes, index)
                : null,
        hrStatusText:
            isHrReviewFlow
                ? (index) => _hrStatusTextAt(_responseHrChecked, index)
                : null,
        autoShowHelp: isCreate,
      );
    }

    if (_currentStep == 2) {
      return AppraisalStepSkillV2(
        skills: _skillItems,
        evidences: _skillControllersForTab(isLeaderReview),
        readOnly: readOnly,
        onRate: (index, value) {
          _updateSkillRating(isLeaderReview, index, value);
        },
        onEvidenceChanged:
            (index, value) =>
                _updateSkillEvidence(isLeaderReview, index, value),
        isLeaderReview: isLeaderReview,
        onItemTap: isHrReviewFlow ? _onHrSkillTap : null,
        hrNoteText:
            isHrReviewFlow ? (index) => _hrNoteAt(_skillHrNotes, index) : null,
        hrStatusText:
            isHrReviewFlow
                ? (index) => _hrStatusTextAt(_skillHrChecked, index)
                : null,
        autoShowHelp: isCreate,
      );
    }

    if (_currentStep == 3) {
      return AppraisalStepExperienceV2(
        experiences: _experienceItems,
        jobTitles: state.jobTitles ?? const [],
        projectControllers: _experienceProjectControllers,
        fromDateControllers: _experienceFromDateControllers,
        toDateControllers: _experienceToDateControllers,
        techniqueControllers: _experienceTechniqueControllers,
        numberPeopleControllers: _experienceNumberPeopleControllers,
        noteControllers: _experienceNoteControllers,
        isLeaderReview: isLeaderReview,
        readOnly: readOnly || isLeaderReview,
        onAddCriteria:
            (!readOnly && !isLeaderReview) ? _addExperienceCriteria : null,
        onRemoveItem:
            (!readOnly && !isLeaderReview) ? _removeExperienceCriteria : null,
        onProjectChanged: _updateExperienceProject,
        onTechniqueChanged: _updateExperienceTechnique,
        onNumberPeopleChanged: _updateExperienceNumberPeople,
        onNoteChanged: _updateExperienceNote,
        onPositionChanged: _updateExperiencePosition,
        onDateFromChanged: _updateExperienceDateFrom,
        onDateToChanged: _updateExperienceDateTo,
        autoShowHelp: isCreate,
      );
    }

    return AppraisalStepOpinionV2(
      suggests: _suggestItems,
      controllers: _suggestControllers,
      isLeaderReview: isLeaderReview,
      isHrReview: isHrReviewFlow,
      readOnly: readOnly,
      onNoteChanged: _updateSuggestNote,
      evaluationState: state.detailEvaluation?.state,
      onItemTap: isHrReviewFlow ? _onHrSuggestTap : null,
      hrNoteText:
          isHrReviewFlow ? (index) => _hrNoteAt(_suggestHrNotes, index) : null,
      hrStatusText:
          isHrReviewFlow
              ? (index) => _hrStatusTextAt(_suggestHrChecked, index)
              : null,
      autoShowHelp: isCreate,
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
    _disposeControllers(_experienceProjectControllers);
    _disposeControllers(_experienceFromDateControllers);
    _disposeControllers(_experienceToDateControllers);
    _disposeControllers(_experienceTechniqueControllers);
    _disposeControllers(_experienceNumberPeopleControllers);
    _disposeControllers(_experienceNoteControllers);
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
          if (_isManagerAssessFlow) {
            AppSnackBar.showInfo(
              title: s.success,
              message:
                  state.errMsg?.isNotEmpty == true
                      ? state.errMsg
                      : 'Đánh giá thành công',
            );
            context.read<CreateAppraisalCubit>().resetUpdateStatus();
            _isManagerAssessFlow = false;
            _closeFlow(state.detailEvaluation);
            return;
          }

          if (_isHrAssessFlow) {
            AppSnackBar.showInfo(
              title: s.success,
              message:
                  state.errMsg?.isNotEmpty == true
                      ? state.errMsg
                      : 'Đánh giá HR thành công',
            );
            context.read<CreateAppraisalCubit>().resetUpdateStatus();
            _isHrAssessFlow = false;
            _closeFlow(state.detailEvaluation);
            return;
          }

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
          _isManagerAssessFlow = false;
          _isHrAssessFlow = false;
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
          final isManagerAssessFlow = state.isManagerAssess == true;
          final isHrReviewFlow =
              !isManagerAssessFlow &&
              (state.isHRReview == true ||
                  (state.isEdit == true &&
                      _isHrReviewer &&
                      state.currentTabIndex == 1));
          final isLeaderReview =
              state.currentTabIndex == 1 &&
              (isManagerAssessFlow || (!isHrReviewFlow && !isCreate));
          final isSelfReviewLocked = _isSelfReviewLocked(state, isLeaderReview);
          final canProceed = _canProceed(
            isDetail: isDetail,
            isLeaderReview: isLeaderReview,
            isHrReviewFlow: isHrReviewFlow,
            isSelfReviewLocked: isSelfReviewLocked,
          );

          if (!_didHydrateDetail && state.detailEvaluation != null) {
            _hydrateDetail(state);
          }

          if (isCreate && !_didInitializeCreate) {
            _initializeCreateDefaults();
            _fillTotalByStep(state, isLeaderReview: false);
          }

          final actionText =
              _currentStep < _lastStepIndex
                  ? s.appraisal_next
                  : (isManagerAssessFlow || isHrReviewFlow)
                  ? s.save
                  : state.isEdit == true && !isSelfReviewLocked
                  ? s.save
                  : s.confirm;

          return Scaffold(
            backgroundColor: AppTokensV2.bgDeep,
            body: AmbientBackgroundV2(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTopBarV2(s),
                      const SizedBox(height: 12),
                      if (!isCreate && !isHrReviewFlow) ...[
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
                              _buildStepContent(
                                isDetail,
                                state,
                                isLeaderReview,
                              ),
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
                                child: _ActionButtonV2(
                                  label: s.appraisal_back,
                                  enable: true,
                                  isLoading: false,
                                  isPrimary: false,
                                  onTap: _back,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButtonV2(
                                  label: actionText,
                                  enable:
                                      state.updateStatus !=
                                          LoadStatus.LOADING &&
                                      canProceed,
                                  isLoading:
                                      state.isEdit == true &&
                                      _currentStep == _lastStepIndex &&
                                      state.updateStatus == LoadStatus.LOADING,
                                  isPrimary: true,
                                  onTap: _next,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBarV2(S s) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.maybePop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            s.appraisal_form_title,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        color: AppTokensV2.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTokensV2.border),
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
                            isSelected
                                ? AppTokensV2.accent.withValues(alpha: 0.18)
                                : Colors.transparent,
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
                                  ? AppTokensV2.accent
                                  : AppTokensV2.fgSoft,
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

/// Nút Quay lại / Tiếp tục / Lưu dùng riêng cho orchestrator v2 — tái tạo
/// đúng 3 trạng thái enable/disable/loading của `PrimaryButton` gốc (bản gốc
/// dùng [PrimaryButtonType.secondary] cho nút "Quay lại" và primary cho nút
/// hành động chính), chỉ đổi màu sắc sang tông tối. Không dùng
/// [PrimaryButtonV2] chung vì widget đó chưa có tham số `enable`/`isLoading`.
class _ActionButtonV2 extends StatelessWidget {
  final String label;
  final bool enable;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButtonV2({
    required this.label,
    required this.enable,
    required this.isLoading,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canPress = enable && !isLoading;

    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap:
              canPress
                  ? () {
                    HapticFeedback.selectionClick();
                    onTap();
                  }
                  : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: isPrimary && canPress ? AppTokensV2.accentGradient : null,
              color:
                  isPrimary
                      ? (canPress ? null : AppTokensV2.surfaceStrong)
                      : AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPrimary ? Colors.transparent : AppTokensV2.border,
              ),
            ),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                      : Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isPrimary ? FontWeight.w800 : FontWeight.w600,
                          color:
                              isPrimary
                                  ? Colors.white
                                  : (canPress
                                      ? AppTokensV2.fgSoft
                                      : AppTokensV2.fgMuted),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
