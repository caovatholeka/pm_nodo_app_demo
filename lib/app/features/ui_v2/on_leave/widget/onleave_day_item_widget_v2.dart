import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../core/utils/date_utils.dart';

/// Bản tối (v2) của [OnleaveDayItemWidget] — 1 dòng ngày nghỉ trong danh sách
/// chi tiết (ngày + loại nghỉ trong ngày đó). Giữ NGUYÊN cùng data contract:
/// nhận `date`/`type` (mã 'full' | 'before' | 'after') và trả mã đã chọn qua
/// [onTypeChanged], y hệt widget cũ — chỉ đổi trình bày sang tối.
class OnleaveDayItemWidgetV2 extends StatefulWidget {
  final String date;
  final String type;
  final ValueChanged<String>? onTypeChanged;

  const OnleaveDayItemWidgetV2({
    super.key,
    required this.date,
    required this.type,
    this.onTypeChanged,
  });

  @override
  State<OnleaveDayItemWidgetV2> createState() =>
      _OnleaveDayItemWidgetV2State();
}

class _OnleaveDayItemWidgetV2State extends State<OnleaveDayItemWidgetV2> {
  String _labelFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'before':
        return 'Buổi sáng';
      case 'after':
        return 'Buổi chiều';
      case 'full':
      default:
        return 'Cả ngày';
    }
  }

  Future<void> _pickType() async {
    final s = S.of(context);
    final currentCode = (widget.type.isNotEmpty ? widget.type : 'full')
        .toLowerCase();

    final options = const [
      MasterDataItem(text: 'Cả ngày', code: 'full'),
      MasterDataItem(text: 'Buổi sáng', code: 'before'),
      MasterDataItem(text: 'Buổi chiều', code: 'after'),
    ];

    final currentItem = options.firstWhere(
      (e) => (e.code ?? '').toLowerCase() == currentCode,
      orElse: () => const MasterDataItem(text: 'Cả ngày', code: 'full'),
    );

    HapticFeedback.selectionClick();
    final picked = await showModalBottomSheet<MasterDataItem>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppTokensV2.bgTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => _DayTypePickerSheetV2(
            title: s.day_off_card_type,
            options: options,
            currentValue: currentItem,
          ),
    );

    if (picked == null || picked.code == null) return;

    widget.onTypeChanged?.call(picked.code!.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dateText = AppDateUtils.changeIso8601StringToDateTimeString(
      widget.date,
    );
    final typeLabel = _labelFromCode(
      widget.type.isNotEmpty ? widget.type : 'full',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _FieldV2(
              label: s.justification_detail_date,
              value: dateText,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pickType,
              child: _FieldV2(
                label: s.day_off_card_type,
                value: typeLabel,
                suffixIcon: Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldV2 extends StatelessWidget {
  final String label;
  final String value;
  final IconData? suffixIcon;

  const _FieldV2({required this.label, required this.value, this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTokensV2.caption),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  style: AppTokensV2.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffixIcon != null)
                Icon(suffixIcon, size: 18, color: AppTokensV2.fgMuted),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet tối để chọn loại nghỉ trong ngày (Cả ngày/Buổi sáng/Buổi chiều).
class _DayTypePickerSheetV2 extends StatelessWidget {
  final String title;
  final List<MasterDataItem> options;
  final MasterDataItem currentValue;

  const _DayTypePickerSheetV2({
    required this.title,
    required this.options,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: AppTokensV2.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(title, style: AppTokensV2.section),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: AppTokensV2.border),
          ...options.map((item) {
            final isSelected = item.code == currentValue.code;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 2,
              ),
              title: Text(
                item.text ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? AppTokensV2.accent : AppTokensV2.fg,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              trailing:
                  isSelected
                      ? Icon(
                        Icons.check_rounded,
                        color: AppTokensV2.accent,
                        size: 20,
                      )
                      : null,
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context, item);
              },
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
