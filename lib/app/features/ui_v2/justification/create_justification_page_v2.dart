import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/keyboard_done_bar_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/features/ui/justification/bloc/create_justification_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Tạo/Sửa đơn muộn/sớm — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [CreateJustificationPage]: cùng
/// [CreateJustificationCubit] (khởi tạo trực tiếp qua `context.read()` +
/// `initFromDetail`), cùng field/thứ tự (loại lý do, ngày, hình thức
/// muộn/sớm kèm số giờ, ghi chú), cùng validate (`state.isFormValid`), cùng
/// cách xử lý tạo/sửa và kết quả (pop true + flushbar). Chỉ đổi trình bày
/// sang hệ thiết kế v2.
class CreateJustificationPageV2 extends StatefulWidget {
  final JustificationEntity? initialData;

  const CreateJustificationPageV2({super.key, this.initialData});

  bool get isEdit => initialData != null;

  @override
  State<CreateJustificationPageV2> createState() =>
      _CreateJustificationPageV2State();
}

class _CreateJustificationPageV2State
    extends State<CreateJustificationPageV2> {
  late final TextEditingController _noteCtrl;
  final Map<String, TextEditingController> _hourControllers = {};

  @override
  void initState() {
    super.initState();

    final e = widget.initialData;
    _noteCtrl = TextEditingController(text: e?.note ?? '');

    if (e != null && e.exceptionLines != null) {
      for (var line in e.exceptionLines!) {
        if (line.formType != null && line.timeNumber != null) {
          _hourControllers[line.formType!] = TextEditingController(
            text: line.timeNumber!.toString(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    for (var ctrl in _hourControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _goNotification() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
              child: const NotificationPage(),
            ),
      ),
    );
  }

  void _showDatePicker(BuildContext context, CreateJustificationCubit cubit) {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      currentTime: DateTime.now(),
      onConfirm: (date) {
        final value = DateFormat('yyyy-MM-dd').format(date);
        cubit.changeDate(value);
      },
    );
  }

  TextEditingController _getHourController(String formType) {
    if (!_hourControllers.containsKey(formType)) {
      _hourControllers[formType] = TextEditingController();
    }
    return _hourControllers[formType]!;
  }

  Future<void> _openReasonTypeSheet(
    BuildContext context,
    CreateJustificationCubit cubit,
    String? currentValue,
  ) async {
    HapticFeedback.selectionClick();
    final s = S.of(context);
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTokensV2.bgTop,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => _ReasonTypePickerSheetV2(
            title: s.justification_create_reasonType,
            currentValue: currentValue,
            personalLabel: s.justification_personal,
            workLabel: s.justification_work,
          ),
    );
    if (result == null) return;
    cubit.changeReason(result);
  }

  String _reasonDisplayText(String? reasonType) {
    if (reasonType == 'personal') return 'Việc cá nhân';
    if (reasonType == 'work') return 'Công việc';
    return '';
  }

  String _formTypeLabel(String formType) {
    return formType == 'late' ? 'Đi muộn' : 'Về sớm';
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create:
          (context) =>
              CreateJustificationCubit(context.read())
                ..initFromDetail(widget.initialData),
      child: BlocConsumer<CreateJustificationCubit, CreateJustificationState>(
        listenWhen:
            (p, c) =>
                p.errorMessage != c.errorMessage || p.isSuccess != c.isSuccess,
        listener: (context, state) async {
          if (state.errorMessage != null) {
            await Flushbar(
              message: state.errorMessage!,
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ).show(context);
            return;
          }

          if (state.isSuccess == true) {
            Navigator.of(context).pop(true);
            await Flushbar(
              message:
                  widget.isEdit
                      ? s.justification_updateSuscess
                      : s.justification_createSuscess,
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ).show(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<CreateJustificationCubit>();

          return Scaffold(
            backgroundColor: AppTokensV2.bgDeep,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.maybePop(context),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTokensV2.fg,
                  size: 20,
                ),
              ),
              title: Text(
                widget.isEdit
                    ? s.justification_update_title
                    : s.justification_create_title,
                style: AppTokensV2.title,
              ),
              centerTitle: false,
              actions: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _goNotification,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      border: Border.all(color: AppTokensV2.border),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppTokensV2.fgSoft,
                    ),
                  ),
                ),
              ],
            ),
            body: AmbientBackgroundV2(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    MediaQuery.of(context).padding.top > 0 ? 8 : 18,
                    18,
                    120,
                  ),
                  child: StaggerRevealV2(
                    index: 0,
                    child: GlassCardV2(
                      radius: AppTokensV2.radius,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _reasonTypeField(context, cubit, state),
                          const SizedBox(height: 16),
                          _dateField(context, cubit, state),
                          const SizedBox(height: 16),
                          _formTypeField(context, cubit, state),
                          if ((state.selectedFormTypes ?? []).isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...state.selectedFormTypes!.map(
                              (formType) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _hourRow(cubit, formType),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          _noteField(cubit),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomSheet: KeyboardDoneBarV2(child: _bottomSheet(cubit, state)),
          );
        },
      ),
    );
  }

  Widget _fieldLabel(String title, {bool required = true}) {
    return Row(
      children: [
        Text(title, style: AppTokensV2.caption),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _reasonTypeField(
    BuildContext context,
    CreateJustificationCubit cubit,
    CreateJustificationState state,
  ) {
    final value = _reasonDisplayText(state.reasonType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).justification_create_reasonType),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openReasonTypeSheet(context, cubit, state.reasonType),
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
              border: Border.all(color: AppTokensV2.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: value.isNotEmpty
                        ? AppTokensV2.body
                        : AppTokensV2.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppTokensV2.fgMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField(
    BuildContext context,
    CreateJustificationCubit cubit,
    CreateJustificationState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).justification_create_date),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            _showDatePicker(context, cubit);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
              border: Border.all(color: AppTokensV2.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.date ?? '',
                    style: (state.date ?? '').isNotEmpty
                        ? AppTokensV2.body
                        : AppTokensV2.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppTokensV2.fgMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _formTypeField(
    BuildContext context,
    CreateJustificationCubit cubit,
    CreateJustificationState state,
  ) {
    const options = [
      {"value": "late", "label": "Đi muộn"},
      {"value": "early", "label": "Về sớm"},
    ];
    final selected = state.selectedFormTypes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).justification_create_form),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final value = opt["value"] as String;
            final label = opt["label"] as String;
            final isSelected = selected.contains(value);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                final newValues = List<String>.from(selected);
                if (isSelected) {
                  newValues.remove(value);
                } else {
                  newValues.add(value);
                }
                cubit.changeSelectedFormTypes(newValues);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTokensV2.accent.withValues(alpha: 0.2)
                      : AppTokensV2.surfaceStrong,
                  border: Border.all(
                    color: isSelected ? AppTokensV2.accent : AppTokensV2.border,
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTokensV2.accent : AppTokensV2.fgSoft,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _hourRow(CreateJustificationCubit cubit, String formType) {
    final controller = _getHourController(formType);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).justification_method, style: AppTokensV2.caption),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(minHeight: 46),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTokensV2.surface,
                  borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                  border: Border.all(color: AppTokensV2.border),
                ),
                child: Text(_formTypeLabel(formType), style: AppTokensV2.body),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(S.of(context).justification_create_hours),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTokensV2.surfaceStrong,
                  borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
                  border: Border.all(color: AppTokensV2.border),
                ),
                child: TextField(
                  scrollPadding: kFormFieldScrollPaddingV2,
                  controller: controller,
                  style: AppTokensV2.body,
                  cursorColor: AppTokensV2.accent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  ],
                  onChanged: (v) {
                    final value = double.tryParse(v);
                    if (value != null) {
                      cubit.changeFormHours(formType, value);
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _noteField(CreateJustificationCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(S.of(context).justification_create_notes),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: TextField(
            scrollPadding: kFormFieldScrollPaddingV2,
            controller: _noteCtrl,
            maxLength: InputLimits.requestNote,
            buildCounter: inputCounterV2(),
            maxLines: 6,
            style: AppTokensV2.body,
            cursorColor: AppTokensV2.accent,
            onChanged: cubit.changeNote,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              hintText: '',
              hintStyle: AppTokensV2.caption,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomSheet(
    CreateJustificationCubit cubit,
    CreateJustificationState state,
  ) {
    final isEnable = state.isFormValid;
    final isLoading = state.isSubmitting;

    return Container(
      margin: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).padding.bottom + 18,
        top: 0,
      ),
      child: isLoading
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: AppTokensV2.accentGradient,
                borderRadius: BorderRadius.circular(15),
              ),
              // heightFactor: 1 — nút nằm trong bottomSheet (chiều cao tối đa = cả màn hình);
              // Center không có nó sẽ giãn hết cỡ → khối xanh che kín màn hình khi đang lưu.
              child: const Center(
                heightFactor: 1,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : isEnable
              ? PrimaryButtonV2(
                  label: S.of(context).justification_create_savebtn,
                  onTap: cubit.submit,
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTokensV2.surfaceStrong,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppTokensV2.border),
                  ),
                  child: Text(
                    S.of(context).justification_create_savebtn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTokensV2.fgMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
    );
  }
}

/// Bottom sheet tối để chọn loại lý do (việc cá nhân / công việc). Tương
/// đương bottom sheet trong [CreateJustificationPage] bản cũ nhưng theo hệ
/// thiết kế v2 — trả về mã loại lý do ('personal'/'work') qua `Navigator.pop`.
class _ReasonTypePickerSheetV2 extends StatelessWidget {
  final String title;
  final String? currentValue;
  final String personalLabel;
  final String workLabel;

  const _ReasonTypePickerSheetV2({
    required this.title,
    required this.currentValue,
    required this.personalLabel,
    required this.workLabel,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"code": "personal", "text": personalLabel},
      {"code": "work", "text": workLabel},
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTokensV2.section,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 22,
                    color: AppTokensV2.fgSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: AppTokensV2.border),
          ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder:
                (_, __) => Divider(height: 1, thickness: 1, color: AppTokensV2.border),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = currentValue == item["code"];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
                title: Text(
                  item["text"]!,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected ? AppTokensV2.accent : AppTokensV2.fg,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: AppTokensV2.accent,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, item["code"]);
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
