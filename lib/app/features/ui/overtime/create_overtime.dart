import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class CreateOTPage extends StatefulWidget {
  final OvertimeEntity? initialData;

  const CreateOTPage({super.key, this.initialData});

  bool get isEdit => initialData != null;

  @override
  State<CreateOTPage> createState() => _CreateOTPageState();
}

class _CreateOTPageState extends State<CreateOTPage> {
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
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _fromDate = d;
        _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _hourControllers.clear();
        _cubit.setFromDate(DateFormat('yyyy-MM-dd').format(d));
        setState(() {});
      },
    );
  }

  void _pickToDate() {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _toDate = d;
        _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        _hourControllers.clear();
        _cubit.setToDate(DateFormat('yyyy-MM-dd').format(d));
        if (_fromDate != null) {
          _cubit.initOvertimeLines(_generateDays(_fromDate!, _toDate!));
        }
        setState(() {});
      },
    );
  }

  void _goNotification() {
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CreateOvertimeCubit, CreateOvertimeState>(
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
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: BlocBuilder<AppCubit, AppState>(
                    buildWhen:
                        (prev, cur) => prev.totalUnread != cur.totalUnread,
                    builder: (context, appState) {
                      return MyAppBar(
                        titleAppbar: widget.isEdit?
                            S.of(context).ot_update_title
                            : S.of(context).ot_create_title 
                        ,
                        haveBackButton: true,
                        haveActionButton: true,
                        iconPathAsset: AppAssets.icNotificationBell,
                        badgeCount: appState.totalUnread,
                        actionCallBack: () async {
                          _goNotification();
                        },
                      );
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        InputTextField(
                          title: S.of(context).ot_input_date,
                          hintText: '',
                          isRequiredField: false,
                          controller: _createdDateCtrl,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InputTextField(
                                title: S.of(context).ot_input_fromDate,
                                hintText: '',
                                isRequiredField: true,
                                controller: _fromDateCtrl,
                                readOnly: true,
                                suffixIcon: AppAssets.icCalendar,
                                callback: _pickFromDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputTextField(
                                title: S.of(context).ot_input_toDate,
                                hintText: '',
                                isRequiredField: true,
                                controller: _toDateCtrl,
                                readOnly: true,
                                suffixIcon: AppAssets.icCalendar,
                                callback: _pickToDate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_showOTDetail)
                          ..._generateDays(_fromDate!, _toDate!)
                              .asMap()
                              .entries
                              .map((e) => _otDayBlock(e.key, e.value)),
                        InputTextField(
                          title: S.of(context).ot_input_notes,
                          hintText: '',
                          isRequiredField: true,
                          controller: _noteCtrl,
                          maxLine: 5,
                          onChange: _cubit.setNote,
                        ),
                      ],
                    ),
                  ),
                ),
                bottomSheet: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 48,
                      child: PrimaryButton(
                        mainText: widget.isEdit ? s.justification_detail_updatebtn : s.send_approval_btn,
                        enable: state.isFormValid,
                        isLoading: state.isSubmitting,
                        callback: _cubit.submit,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          InputTextField(
            title: S.of(context).ot_input_Date,
            hintText: '',
            isRequiredField: false,
            controller: TextEditingController(
              text: DateFormat('dd/MM/yyyy').format(date),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InputTextField(
                  title: S.of(context).ot_input_totalTime,
                  hintText: '',
                  isRequiredField: true,
                  controller: controller,
                  inputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  onChange: (v) {
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
                child: DropdownInputField(
                  title: S.of(context).ot_input_recevice,
                  hint: '',
                  isRequired: true,
                  items: const ['Trả tiền', 'Quỹ nghỉ phép'],
                  selectedValue:
                      line?.formType == 'pay'
                          ? 'Trả tiền'
                          : line?.formType == 'leave'
                          ? 'Quỹ nghỉ phép'
                          : null,
                  onChanged: (v) {
                    _cubit.updateOvertimeLine(
                      index,
                      OvertimeLineEntity(
                        date: line?.date,
                        overtime: line?.overtime,
                        formType: v == 'Trả tiền' ? 'pay' : 'leave',
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

  String _formatHour(double hour) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
