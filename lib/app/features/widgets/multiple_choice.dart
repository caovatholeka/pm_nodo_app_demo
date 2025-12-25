import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

enum ChoiceType { single, multiple }

class MultipleChoiceField<T> extends StatelessWidget {
  final String title;
  final String hint;
  final bool isRequired;

  final ChoiceType type;
  final List<Map<String, dynamic>> options;

  final T? selectedValue;
  final List<T>? selectedValues;

  final ValueChanged<T>? onSingleChanged;
  final ValueChanged<List<T>>? onMultiChanged;

  const MultipleChoiceField({
    super.key,
    required this.title,
    required this.hint,
    required this.options,
    required this.type,
    this.selectedValue,
    this.selectedValues,
    this.onSingleChanged,
    this.onMultiChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: _displayText());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _openBottomSheet(context),
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: hint,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      AppAssets.icArrowDown,
                      width: 12,
                      height: 12,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayText() {
    if (type == ChoiceType.multiple &&
        selectedValues != null &&
        selectedValues!.isNotEmpty) {
      return options
          .where((e) => selectedValues!.contains(e["value"]))
          .map((e) => e["label"])
          .join(", ");
    }
    return "";
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        List<T> tempSelected = List<T>.from(selectedValues ?? []);

        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Colors.black12,
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Colors.black12,
                          ),
                      itemBuilder: (context, index) {
                        final opt = options[index];
                        final value = opt["value"] as T;
                        final label = opt["label"];
                        final isSelected = tempSelected.contains(value);

                        return ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                isSelected
                                    ? const Color(0xFF2563EB)
                                    : Colors.grey,
                          ),
                          title: Text(label),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                tempSelected.remove(value);
                              } else {
                                tempSelected.add(value);
                              }
                            });
                            onMultiChanged?.call(tempSelected);
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
      },
    );
  }
}
