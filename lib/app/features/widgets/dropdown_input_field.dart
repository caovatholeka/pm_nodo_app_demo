import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'input_text_field.dart';

class DropdownInputField extends StatelessWidget {
  final String title;
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const DropdownInputField({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: selectedValue ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

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
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Colors.black12,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final bool isSelected = item == selectedValue;

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            title: Text(
                              item,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? const Color.fromARGB(255, 0, 62, 255)
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
        },
        child: AbsorbPointer(
          child: InputTextField(
            title: title,
            hintText: hint,
            isRequiredField: false,
            enable: true,
            readOnly: true,
            controller: controller,
            suffixIcon: AppAssets.icArrowDown,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
            bgrColor: true,
          ),
        ),
      ),
    );
  }
}
