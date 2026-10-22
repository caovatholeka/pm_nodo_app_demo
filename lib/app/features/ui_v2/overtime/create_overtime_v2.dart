import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Tạo/Sửa đơn tăng ca — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [CreateOTPage]: tạo mới
/// [CreateOvertimeCubit] riêng (không lấy từ GetIt), cùng cách khởi tạo dữ
/// liệu khi sửa (initFromDetail/setFromDate/setToDate/setNote/
/// initOvertimeLines/updateOvertimeLine), cùng luật chọn ngày (không cho
/// chọn lại từ/đến khi đã có danh sách -> xoá lại danh sách giờ nhập), cùng
/// điều kiện bật nút lưu ([CreateOvertimeState.isFormValid]), cùng xử lý
/// thành công/thất bại. Chỉ đổi trình bày sang hệ thiết kế v2.
class CreateOTPageV2 extends StatefulWidget {
  final OvertimeEntity? initialData;

  const CreateOTPageV2({super.key, this.initialData});

  bool get isEdit => initialData != null;

  @override
  State<CreateOTPageV2> createState() => _CreateOTPageV2State();
}

class _CreateOTPageV2State extends State<CreateOTPageV2> {
  late final CreateOvertimeCubit _cubit;

  final _createdDateCtrl = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  final _fromDateCtrl = TextEditingController();
  final _toDateCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final Map<int, TextEditingController> _hourControllers = {};

  DateTime? _fromDate;
  DateTime? _toDate;

  bool get _showOTDetail => _fromDate != null && _toDate != null;

  @override
  void initState() {
    super.initState();
    _cubit = CreateOvertimeCubit();

    final e = widget.initialData;

    if (e != null) {
      _fromDate = DateTime.parse(e.fromDate!);
      _toDate = DateTime.parse(e.toDate!);

      _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(_fromDate!);
      _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(_toDate!);
      _noteCtrl.text = e.note ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hourControllers.clear();

        _cubit.initFromDetail(e.id!);
        _cubit.setFromDate(e.fromDate!);
        _cubit.setToDate(e.toDate!);
        _cubit.setNote(e.note);

        final days = _generateDays(_fromDate!, _toDate!);
        _cubit.initOvertimeLines(days);

        for (var i = 0; i < e.overtimeDetail!.length; i++) {
          final d = e.overtimeDetail![i];
          _cubit.updateOvertimeLine(
            i,
            OvertimeLineEntity(
              date: d.date,
              overtime: d.overtime?.toDouble(),
              formType: d.formType,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _createdDateCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _hourControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickFromDate() {
    HapticFeedback.selectionClick();
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      maxTime: _toDate, // "Từ ngày" không được sau "Đến ngày"
      onConfirm: (d) {
        _fromDate = d;
        _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _hourControllers.clear();
        _cubit.setFromDate(DateFormat('yyyy-MM-dd').format(d));
        _syncOvertimeLines();
        setState(() {});
      },
    );
  }

  void _pickToDate() {
    HapticFeedback.selectionClick();
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      minTime: _fromDate, // "Đến ngày" không được trước "Từ ngày"
      onConfirm: (d) {
        _toDate = d;
        _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _hourControllers.clear();
        _cubit.setToDate(DateFormat('yyyy-MM-dd').format(d));
        _syncOvertimeLines();
        setState(() {});
      },
    );
  }

  /// Đủ cả 2 ngày thì tạo lại danh sách ngày OT trong cubit (dữ liệu gửi đi). Trước đây
  /// chỉ làm khi chọn "Đến ngày" → chọn "Đến ngày" trước rồi mới chọn "Từ ngày" thì danh
  /// sách gửi đi rỗng (màn hình vẫn hiện các ngày) → không gửi được; đổi "Từ ngày" sau
  /// cùng thì danh sách gửi đi lệch với màn hình.
  void _syncOvertimeLines() {
    if (_fromDate != null && _toDate != null) {
      _cubit.initOvertimeLines(_generateDays(_fromDate!, _toDate!));
    }
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

  List<DateTime> _generateDays(DateTime from, DateTime to) {
    final days = <DateTime>[];
    var current = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CreateOvertimeCubit, CreateOvertimeState>(
        listenWhen:
            (p, c) =>
                p.isSubmitting != c.isSubmitting ||
                p.errorMessage != c.errorMessage ||
                p.isSuccess != c.isSuccess,
        listener: (context, state) async {
          if (state.isSubmitting) {
            LoadingOverlay.show(context);
            return;
          }

          LoadingOverlay.hide(context);

          if (state.errorMessage != null) {
            await Flushbar(
              message: state.errorMessage!,
              flushbarPosition: FlushbarPosition.TOP,
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ).show(context);
            return;
          }

          if (state.isSuccess) {
            Navigator.pop(context, true);
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
                widget.isEdit ? s.ot_update_title : s.ot_create_title,
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
                          _readOnlyField(
                            title: s.ot_input_date,
                            value: _createdDateCtrl.text,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _dateBox(
                                  title: s.ot_input_fromDate,
                                  value: _fromDateCtrl.text,
                                  onTap: _pickFromDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _dateBox(
                                  title: s.ot_input_toDate,
                                  value: _toDateCtrl.text,
                                  onTap: _pickToDate,
                                ),
                              ),
                            ],
                          ),
                          if (_showOTDetail) ...[
                            const SizedBox(height: 16),
                            ..._generateDays(_fromDate!, _toDate!)
                                .asMap()
                                .entries
                                .map((e) => _otDayBlock(e.key, e.value)),
                          ],
                          const SizedBox(height: 16),
                          _reasonField(state),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomSheet: _bottomSheet(state),
          );
        },
      ),
    );
  }

  Widget _readOnlyField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTokensV2.caption),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTokensV2.surface,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: Text(value, style: AppTokensV2.body),
        ),
      ],
    );
  }

  Widget _dateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTokensV2.caption),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
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
                    style:
                        value.isNotEmpty
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

  Widget _otDayBlock(int index, DateTime date) {
    final line =
        _cubit.state.overtimeLines.length > index
            ? _cubit.state.overtimeLines[index]
            : null;

    final controller = _hourControllers.putIfAbsent(
      index,
      () => TextEditingController(text: line?.overtime?.toString() ?? ''),
    );

    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _readOnlyField(
            title: s.ot_input_Date,
            value: DateFormat('dd/MM/yyyy').format(date),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _hourField(
                  title: s.ot_input_totalTime,
                  controller: controller,
                  onChanged: (v) {
                    if (v.isEmpty) {
                      _cubit.updateOvertimeLine(
                        index,
                        OvertimeLineEntity(
                          date: line?.date,
                          overtime: null,
                          formType: line?.formType,
                        ),
                      );
                      return;
                    }

                    final h = double.tryParse(v);
                    if (h == null) return;

                    _cubit.updateOvertimeLine(
                      index,
                      OvertimeLineEntity(
                        date: line?.date,
                        overtime: h,
                        formType: line?.formType,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _formTypeField(
                  title: s.ot_input_recevice,
                  formType: line?.formType,
                  onChanged: (v) {
                    _cubit.updateOvertimeLine(
                      index,
                      OvertimeLineEntity(
                        date: line?.date,
                        overtime: line?.overtime,
                        formType: v,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hourField({
    required String title,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTokensV2.caption),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 46),
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: TextField(
            controller: controller,
            style: AppTokensV2.body,
            cursorColor: AppTokensV2.accent,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bản v2 thay [DropdownInputField] (2 lựa chọn: pay/leave) bằng 2 chip
  /// chọn 1 — cùng data contract (`formType` là 'pay' | 'leave' | null, trả
  /// về qua [onChanged]) như bản cũ.
  Widget _formTypeField({
    required String title,
    required String? formType,
    required ValueChanged<String> onChanged,
  }) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTokensV2.caption),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _formTypeChip(
                label: s.ot_paid,
                selected: formType == 'pay',
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged('pay');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _formTypeChip(
                label: s.ot_timeOff,
                selected: formType == 'leave',
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged('leave');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _formTypeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppTokensV2.accent.withValues(alpha: 0.2)
                  : AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
          border: Border.all(
            color: selected ? AppTokensV2.accent : AppTokensV2.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppTokensV2.accent : AppTokensV2.fgSoft,
          ),
        ),
      ),
    );
  }

  Widget _reasonField(CreateOvertimeState state) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(s.ot_input_notes, style: AppTokensV2.caption),
            const SizedBox(width: 4),
            Text(
              "*",
              style: TextStyle(color: AppTokensV2.danger, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
            border: Border.all(color: AppTokensV2.border),
          ),
          child: TextField(
            controller: _noteCtrl,
            maxLines: 5,
            style: AppTokensV2.body,
            cursorColor: AppTokensV2.accent,
            onChanged: _cubit.setNote,
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

  Widget _bottomSheet(CreateOvertimeState state) {
    final s = S.of(context);
    final label = widget.isEdit ? s.justification_detail_updatebtn : s.send_approval_btn;

    return Container(
      margin: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).padding.bottom + 18,
        top: 0,
      ),
      child:
          state.isFormValid
              ? PrimaryButtonV2(label: label, onTap: _cubit.submit)
              : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppTokensV2.surfaceStrong,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTokensV2.border),
                ),
                child: Text(
                  label,
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
