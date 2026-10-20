import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/experience_id_entity.dart';
import 'package:pm_app/app/data/models/entities/job_title_entity.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

import '../widgets/appraisal_help_tooltip_v2.dart';

/// Bản tối (v2) của [AppraisalStepExperience]
/// (`lib/app/features/ui/appraisal_form/steps/appraisal_step_experience.dart`).
/// Cùng constructor/callback, cùng controller/logic ngày tháng — chỉ đổi màu
/// sang tông tối.
///
/// LƯU Ý (đã báo trong report): [DropdownInputField] (widget dùng chung ở
/// `lib/app/features/widgets/dropdown_input_field.dart`) không có tham số
/// tuỳ biến màu nền/chữ — nó luôn vẽ nền trắng/chữ tối. Vì không được sửa
/// widget dùng chung ngoài phạm vi task, trường "Vị trí công việc" ở bản v2
/// này sẽ hiển thị với màu gốc (sáng) thay vì tối hoàn toàn.
class AppraisalStepExperienceV2 extends StatelessWidget {
  AppraisalStepExperienceV2({
    super.key,
    required this.experiences,
    required this.jobTitles,
    required this.projectControllers,
    required this.fromDateControllers,
    required this.toDateControllers,
    required this.techniqueControllers,
    required this.numberPeopleControllers,
    required this.noteControllers,
    required this.onProjectChanged,
    required this.onTechniqueChanged,
    required this.onNumberPeopleChanged,
    required this.onNoteChanged,
    required this.onPositionChanged,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    this.onAddCriteria,
    this.onRemoveItem,
    this.onItemTap,
    this.hrNoteText,
    this.hrStatusText,
    this.readOnly = false,
    this.isLeaderReview = false,
    this.autoShowHelp = false,
  });

  final List<ExperienceIdEntity> experiences;
  final List<JobTitleEntity> jobTitles;
  final List<TextEditingController> projectControllers;
  final List<TextEditingController> fromDateControllers;
  final List<TextEditingController> toDateControllers;
  final List<TextEditingController> techniqueControllers;
  final List<TextEditingController> numberPeopleControllers;
  final List<TextEditingController> noteControllers;
  final void Function(int index, String value) onProjectChanged;
  final void Function(int index, String value) onTechniqueChanged;
  final void Function(int index, String value) onNumberPeopleChanged;
  final void Function(int index, String value) onNoteChanged;
  final void Function(int index, int? positionId) onPositionChanged;
  final void Function(int index, DateTime value) onDateFromChanged;
  final void Function(int index, DateTime value) onDateToChanged;
  final VoidCallback? onAddCriteria;
  final void Function(int index)? onRemoveItem;
  final Future<void> Function(int index)? onItemTap;
  final String Function(int index)? hrNoteText;
  final String Function(int index)? hrStatusText;
  final bool readOnly;
  final bool isLeaderReview;
  final bool autoShowHelp;

  final DateFormat _displayDateFormat = DateFormat('MM/yyyy');

  Color get _accent =>
      isLeaderReview ? AppTokensV2.accent2 : AppTokensV2.success;

  static const TextStyle _fieldStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppTokensV2.fg,
  );

  String _displayDate(String? raw) {
    return AppDateUtils.formatFlexibleDateForDisplay(
      raw,
      datePattern: _displayDateFormat.pattern!,
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required String? initialValue,
    required ValueChanged<DateTime> onConfirm,
  }) async {
    final initialDate =
        initialValue == null || initialValue.isEmpty
            ? DateTime.now()
            : _tryParse(initialValue) ?? DateTime.now();

    final locale =
        Localizations.localeOf(context).languageCode == 'en'
            ? LocaleType.en
            : LocaleType.vi;

    await DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: locale,
      pickerModel: _YearMonthPickerV2(
        currentTime: DateTime(initialDate.year, initialDate.month, 1),
        minTime: DateTime(2015, 1, 1),
        maxTime: DateTime(2035, 12, 31),
        locale: locale,
      ),
      onConfirm: onConfirm,
    );
  }

  DateTime? _tryParse(String raw) {
    return AppDateUtils.parseFlexibleDate(raw);
  }

  String? _selectedPositionLabel(int? positionId) {
    for (final item in jobTitles) {
      if (item.id == positionId) {
        return item.name;
      }
    }
    return null;
  }

  TextEditingController _controllerAt(
    List<TextEditingController> controllers,
    int index,
  ) {
    while (controllers.length <= index) {
      controllers.add(TextEditingController());
    }
    return controllers[index];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'IV. Kinh nghiệm làm việc',
                    style: AppTokensV2.body,
                  ),
                  AppraisalHelpTooltipV2(
                    message:
                        'Hãy liệt kê các dự án, vị trí công việc bạn đã làm, mô tả công việc, công nghệ sử dụng, quy mô nhân sự,...',
                    autoShow: autoShowHelp,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTokensV2.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < experiences.length; i++) ...[
                    _buildExperienceCard(context, i),
                    if (i < experiences.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            if (onAddCriteria != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: DashedBorderBox(
                  radius: 14,
                  color: AppTokensV2.accent,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onAddCriteria,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: AppTokensV2.accent, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Thêm tiêu chí',
                              style: TextStyle(
                                color: AppTokensV2.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, int index) {
    final item = experiences[index];
    final projectController = _controllerAt(projectControllers, index);
    final fromDateController = _controllerAt(fromDateControllers, index);
    final toDateController = _controllerAt(toDateControllers, index);
    final techniqueController = _controllerAt(techniqueControllers, index);
    final numberPeopleController = _controllerAt(
      numberPeopleControllers,
      index,
    );
    final noteController = _controllerAt(noteControllers, index);

    if (projectController.text.isEmpty && (item.name ?? '').isNotEmpty) {
      projectController.text = item.name ?? '';
    }
    if (techniqueController.text.isEmpty &&
        (item.techniqueName ?? '').isNotEmpty) {
      techniqueController.text = item.techniqueName ?? '';
    }
    if (numberPeopleController.text.isEmpty &&
        (item.numberPeople ?? '').isNotEmpty) {
      numberPeopleController.text = item.numberPeople ?? '';
    }
    if (noteController.text.isEmpty && (item.note ?? '').isNotEmpty) {
      noteController.text = item.note ?? '';
    }
    fromDateController.text = _displayDate(item.dateFrom);
    toDateController.text = _displayDate(item.dateTo);

    final card = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTokensV2.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    '${index + 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Các việc đã làm',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
              if (!readOnly && onRemoveItem != null && experiences.length > 1)
                IconButton(
                  onPressed: () => onRemoveItem!(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppTokensV2.danger,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          InputTextField(
            title: 'Dự án',
            hintText: 'Nhập tên dự án, công việc,...',
            controller: projectController,
            readOnly: readOnly,
            isRequiredField: true,
            fillBgColor: AppTokensV2.surfaceStrong,
            style: _fieldStyle,
            onChange: (value) => onProjectChanged(index, value),
          ),
          const SizedBox(height: 12),
          DropdownInputField(
            title: 'Vị trí công việc',
            hint:
                jobTitles.isEmpty
                    ? 'Đang tải danh sách công việc'
                    : 'Chọn vị trí công việc',
            items: jobTitles.map((item) => item.name ?? '').toList(),
            selectedValue: _selectedPositionLabel(item.positionId),
            enable: !readOnly && jobTitles.isNotEmpty,
            isRequired: true,
            onChanged: (value) {
              JobTitleEntity? selected;
              for (final position in jobTitles) {
                if (position.name == value) {
                  selected = position;
                  break;
                }
              }
              onPositionChanged(index, selected?.id);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InputTextField(
                  title: 'Từ ngày',
                  hintText: 'MM/YYYY',
                  controller: fromDateController,
                  readOnly: true,
                  isRequiredField: false,
                  fillBgColor: AppTokensV2.surfaceStrong,
                  style: _fieldStyle,
                  suffixIcon: AppAssets.icCalendar,
                  callback:
                      readOnly
                          ? null
                          : () => _pickDate(
                            context,
                            initialValue: item.dateFrom,
                            onConfirm: (value) {
                              onDateFromChanged(index, value);
                            },
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputTextField(
                  title: 'Đến ngày',
                  hintText: 'MM/YYYY',
                  controller: toDateController,
                  readOnly: true,
                  isRequiredField: false,
                  fillBgColor: AppTokensV2.surfaceStrong,
                  style: _fieldStyle,
                  suffixIcon: AppAssets.icCalendar,
                  callback:
                      readOnly
                          ? null
                          : () => _pickDate(
                            context,
                            initialValue: item.dateTo,
                            onConfirm: (value) {
                              onDateToChanged(index, value);
                            },
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InputTextField(
            title: 'Công nghệ sử dụng',
            hintText: 'String boot, React,...',
            controller: techniqueController,
            readOnly: readOnly,
            isRequiredField: false,
            fillBgColor: AppTokensV2.surfaceStrong,
            style: _fieldStyle,
            onChange: (value) => onTechniqueChanged(index, value),
          ),
          const SizedBox(height: 12),
          InputTextField(
            title: 'Quy mô nhân sự',
            hintText: 'Nhập quy mô nhân sự VD: 6 - 10',
            controller: numberPeopleController,
            inputType: TextInputType.number,
            readOnly: readOnly,
            isRequiredField: false,
            fillBgColor: AppTokensV2.surfaceStrong,
            style: _fieldStyle,
            onChange: (value) => onNumberPeopleChanged(index, value),
          ),
          const SizedBox(height: 12),
          InputTextField(
            title: 'Mô tả công việc',
            hintText: 'Nhập mô tả công việc',
            controller: noteController,
            readOnly: readOnly,
            isRequiredField: true,
            maxLine: 4,
            fillBgColor: AppTokensV2.surfaceStrong,
            style: _fieldStyle,
            onChange: (value) => onNoteChanged(index, value),
          ),
          if (hrNoteText != null && hrStatusText != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: AppTokensV2.border),
            const SizedBox(height: 12),
            InputTextField(
              title: 'Ý kiến HR',
              hintText: '',
              initialValue: hrNoteText!(index),
              readOnly: true,
              enable: false,
              isRequiredField: false,
              fillBgColor: AppTokensV2.surface,
              style: _fieldStyle,
            ),
            const SizedBox(height: 12),
            InputTextField(
              title: 'Trạng thái',
              hintText: '',
              initialValue: hrStatusText!(index),
              readOnly: true,
              enable: false,
              isRequiredField: false,
              fillBgColor: AppTokensV2.surface,
              style: _fieldStyle,
            ),
          ],
        ],
      ),
    );

    if (onItemTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onItemTap!(index),
        child: IgnorePointer(ignoring: true, child: card),
      ),
    );
  }
}

class _YearMonthPickerV2 extends CommonPickerModel {
  _YearMonthPickerV2({
    required DateTime currentTime,
    DateTime? minTime,
    DateTime? maxTime,
    super.locale,
  }) {
    this.currentTime = currentTime;
    this.minTime = minTime ?? DateTime(2000, 1, 1);
    this.maxTime = maxTime ?? DateTime(2100, 12, 31);

    setLeftIndex(currentTime.year - this.minTime.year);
    setMiddleIndex(currentTime.month - 1);
    setRightIndex(0);
  }

  late DateTime minTime;
  late DateTime maxTime;

  @override
  String? leftStringAtIndex(int index) {
    final year = minTime.year + index;
    if (year < minTime.year || year > maxTime.year) return null;
    return '$year';
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index < 0 || index > 11) return null;
    final month = index + 1;
    return month.toString().padLeft(2, '0');
  }

  @override
  String? rightStringAtIndex(int index) => '';

  @override
  List<int> layoutProportions() => [2, 2, 0];

  @override
  String leftDivider() => '/';

  @override
  String rightDivider() => '';

  @override
  DateTime finalTime() {
    final year = minTime.year + currentLeftIndex();
    final month = currentMiddleIndex() + 1;
    return DateTime(year, month, 1);
  }
}
