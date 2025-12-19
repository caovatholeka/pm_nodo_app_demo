import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_line_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/create_overtime_cubit.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class CreateOTPage extends StatefulWidget {
  final OvertimeEntity? initialData;

  const CreateOTPage({super.key, this.initialData});

  bool get isEdit => initialData != null;

  @override
  State<CreateOTPage> createState() => _CreateOTPageState();
}

class _CreateOTPageState extends State<CreateOTPage> {
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
    final e = widget.initialData;

    if (e != null) {
      _fromDate = DateTime.parse(e.fromDate!);
      _toDate = DateTime.parse(e.toDate!);

      _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(_fromDate!);
      _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(_toDate!);
      _noteCtrl.text = e.note ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cubit = context.read<CreateOvertimeCubit>();
        cubit.setFromDate(e.fromDate!);
        cubit.setToDate(e.toDate!);
        cubit.setNote(e.note);

        final days = _generateDays(_fromDate!, _toDate!);
        cubit.initOvertimeLines(days);

        for (var i = 0; i < e.overtimeDetail!.length; i++) {
          final d = e.overtimeDetail![i];
          cubit.updateOvertimeLine(
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
    _createdDateCtrl.dispose();
    _fromDateCtrl.dispose();
    _toDateCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _hourControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickFromDate(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _fromDate = d;
        _fromDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);
        context.read<CreateOvertimeCubit>().setFromDate(
          DateFormat('yyyy-MM-dd').format(d),
        );
        setState(() {});
      },
    );
  }

  void _pickToDate(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      locale: LocaleType.vi,
      onConfirm: (d) {
        _toDate = d;
        _toDateCtrl.text = DateFormat('dd/MM/yyyy').format(d);

        final cubit = context.read<CreateOvertimeCubit>();
        cubit.setToDate(DateFormat('yyyy-MM-dd').format(d));

        if (_fromDate != null) {
          cubit.initOvertimeLines(_generateDays(_fromDate!, _toDate!));
        }
        setState(() {});
      },
    );
  }

  List<DateTime> _generateDays(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateOvertimeCubit(),
      child: BlocConsumer<CreateOvertimeCubit, CreateOvertimeState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }

          if (state.submitSuccess) {
            Navigator.pop(context, true);
            context.read<CreateOvertimeCubit>().resetSubmitState();
          }
        },

        builder: (context, state) {
          final cubit = context.read<CreateOvertimeCubit>();

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: MyAppBar(
                  titleAppbar:
                      widget.isEdit
                          ? 'Cập nhật yêu cầu OT'
                          : 'Tạo yêu cầu làm thêm giờ',
                  haveBackButton: true,
                  haveActionButton: true,
                  iconPathAsset: AppAssets.icNotificationBell,
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
                          title: 'Ngày tạo',
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
                                title: 'Từ ngày',
                                isRequiredField: true,
                                hintText: '',
                                controller: _fromDateCtrl,
                                readOnly: true,
                                suffixIcon: AppAssets.icCalendar,
                                callback: () => _pickFromDate(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputTextField(
                                title: 'Đến ngày',
                                hintText: '',
                                isRequiredField: true,
                                controller: _toDateCtrl,
                                readOnly: true,
                                suffixIcon: AppAssets.icCalendar,
                                callback: () => _pickToDate(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_showOTDetail)
                          ..._generateDays(_fromDate!, _toDate!)
                              .asMap()
                              .entries
                              .map((e) => _otDayBlock(cubit, e.key, e.value)),
                        InputTextField(
                          title: 'Ghi chú',
                          hintText: '',
                          isRequiredField: true,
                          controller: _noteCtrl,
                          maxLine: 5,
                          onChange: cubit.setNote,
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
                        mainText: widget.isEdit ? 'Cập nhật' : 'Gửi yêu cầu',
                        isLoading: state.loadStatus == LoadStatus.LOADING,
                        callback: () {
                          if (widget.isEdit) {
                            cubit.update(widget.initialData!.id!);
                          } else {
                            cubit.submit();
                          }
                        },
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

  String _formatHour(double hour) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Widget _otDayBlock(CreateOvertimeCubit cubit, int index, DateTime date) {
    final line =
        cubit.state.overtimeLines.length > index
            ? cubit.state.overtimeLines[index]
            : null;

    _hourControllers.putIfAbsent(
      index,
      () => TextEditingController(
        text: line?.overtime != null ? _formatHour(line!.overtime!) : '',
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          InputTextField(
            title: 'Ngày',
            hintText: '',
            isRequiredField: true,
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
                  title: 'Số giờ',
                  isRequiredField: true,
                  hintText: '',
                  controller: _hourControllers[index],
                  onChange: (v) {
                    final h = double.tryParse(v.replaceAll(':', '.'));
                    if (h == null) return;
                    cubit.updateOvertimeLine(
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
                  title: 'Hình thức nhận',
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
                    cubit.updateOvertimeLine(
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
}
