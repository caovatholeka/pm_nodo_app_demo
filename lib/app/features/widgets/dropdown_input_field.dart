import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class DropdownInputField extends StatelessWidget {
  final String title;
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool isRequired;
  final bool? disableTitle;
  final bool? enable;

  const DropdownInputField({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isRequired = false,
    this.disableTitle,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: selectedValue ?? '');
    
    final fillColor = (enable == true) ? Colors.white : AppColors.lineGray50;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: Colors.black.withAlpha(25)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (disableTitle != true) ...[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppConfig.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (isRequired)
                SvgPicture.asset(AppAssets.starRating),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: GestureDetector(
            onTap: enable == true ? () {
              FocusScope.of(context).unfocus();
              _openBottomSheet(context);
            } : null,
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                enabled: enable,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  hintText: hint,
                  counterText: "",
                  filled: true,
                  fillColor: fillColor,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      AppAssets.icArrowDown,
                      width: 18,
                      height: 18,
                    ),
                  ),
                  border: baseBorder,
                  enabledBorder: baseBorder,
                  focusedBorder: baseBorder,
                  disabledBorder: baseBorder,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: Colors.black12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onChanged(item);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}