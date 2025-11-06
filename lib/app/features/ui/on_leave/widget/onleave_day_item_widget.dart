import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../data/models/entities/master_data_item.dart';
import '../../../widgets/common_bottom_sheet.dart';
import '../../../widgets/custom_bottom_sheet.dart';
import '../../../widgets/input_text_field.dart';

class OnleaveDayItemWidget extends StatefulWidget {
  String date;
  String type;
  final ValueChanged<String>? onTypeChanged;

  OnleaveDayItemWidget({required this.date, required this.type, this.onTypeChanged});

  @override
  State<OnleaveDayItemWidget> createState() => _OnleaveDayItemWidgetState();
}

class _OnleaveDayItemWidgetState extends State<OnleaveDayItemWidget> {
  late TextEditingController _dateCtl;
  late TextEditingController _typeCtl;

  String _labelFromCode(String code) {
    switch ((code).toLowerCase()) {
      case 'before':
        return 'Buổi sáng';
      case 'after':
        return 'Buổi chiều';
      case 'full':
      default:
        return 'Cả ngày';
    }
  }

  String _codeFromLabel(String label) {
    switch (label) {
      case 'Buổi sáng':
        return 'before';
      case 'Buổi chiều':
        return 'after';
      case 'Cả ngày':
      default:
        return 'full';
    }
  }

  @override
  void initState() {
    super.initState();
    _dateCtl = TextEditingController(
      text: AppDateUtils.changeIso8601StringToDateTimeString(widget.date),
    );
    _typeCtl = TextEditingController(
      text: _labelFromCode(widget.type.isNotEmpty ? widget.type : 'full'),
    );
  }

  @override
  void didUpdateWidget(covariant OnleaveDayItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _dateCtl.text =
          AppDateUtils.changeIso8601StringToDateTimeString(widget.date);
    }
    if (oldWidget.type != widget.type) {
      _typeCtl.text =
          _labelFromCode(widget.type.isNotEmpty ? widget.type : 'full');
    }
  }

  @override
  void dispose() {
    _dateCtl.dispose();
    _typeCtl.dispose();
    super.dispose();
  }

  Future<void> _pickType() async {
    final currentCode = (widget.type.isNotEmpty ? widget.type : 'full').toLowerCase();

    final options = const [
      MasterDataItem(text: 'Cả ngày',   code: 'full'),
      MasterDataItem(text: 'Buổi sáng', code: 'before'),
      MasterDataItem(text: 'Buổi chiều',code: 'after'),
    ];

    final currentItem = options.firstWhere(
          (e) => (e.code ?? '').toLowerCase() == currentCode,
      orElse: () => const MasterDataItem(text: 'Cả ngày', code: 'full'),
    );

    final picked = await showModalBottomSheet<MasterDataItem>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommonBottomSheet(
        title: 'Loại nghỉ',
        listValues: options,
        currentValue: currentItem,
      ),
    );

    if (picked == null || (picked.code == null)) return;

    _typeCtl.text = picked.text ?? _labelFromCode(picked.code!);

    widget.onTypeChanged?.call(picked.code!.toLowerCase());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: InputTextField(
            title: "Ngày",
            hintText: "",
            isRequiredField: true,
            readOnly: true,
            controller: _dateCtl,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: _pickType,
            child: IgnorePointer(
              child: InputTextField(
                title: "Loại nghỉ",
                hintText: "",
                isRequiredField: true,
                controller: _typeCtl,
                enable: true,
                readOnly: true,
                suffixIcon: AppAssets.icArrowDown,
              ),
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: 16);
  }
}
