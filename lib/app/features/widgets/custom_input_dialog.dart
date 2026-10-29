import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/generated/l10n.dart';

class CustomInputDialog extends StatelessWidget {
  final String title;
  final String content;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onOk;
  final String okLabel;
  final String? cancelLabel;


  const CustomInputDialog({
    super.key,
    required this.title,
    required this.content,
    required this.controller,
    this.hintText = 'note...',
    this.maxLines = 3,
    this.keyboardType = TextInputType.text,
    this.onCancel,
    this.onOk,
    this.okLabel = 'OK',
    this.cancelLabel,
  });

  static Future<String?> show(
      BuildContext context, {
        String? title,
        String? content,
        String? hintText,
        String? initialValue,
        int maxLines = 3,
        TextInputType keyboardType = TextInputType.text,
        bool barrierDismissible = false,
        String okLabel = 'OK',
        String cancelLabel = 'Cancel',
      }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => CustomInputDialog(
        title: title ?? S.of(ctx).common_enter_content,
        content: content ?? "",
        hintText: hintText ?? S.of(ctx).common_enter_here_hint,
        maxLines: maxLines,
        keyboardType: keyboardType,
        controller: controller,
        okLabel: okLabel,
        cancelLabel: cancelLabel,
        onCancel: () => Navigator.of(ctx).pop(null),
        onOk: (text) => Navigator.of(ctx).pop(text.trim()),
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.themeBlackDefault
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close),
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                )
              ],
            ),
            if (content.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGray600
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Input
            InputTextField(
                title: "",
                disableTitle: true,
                hintText: hintText,
                isRequiredField: false,
              maxLine: maxLines,
              controller: controller,
              inputType: keyboardType,
              enable: true,
              onSubmited: (v) {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) onOk?.call(text);
              },
            ),
            const SizedBox(height: 14),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final okEnabled = value.text.trim().isNotEmpty;
                return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onCancel ?? () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                              width: 1,
                              color: AppColors.themeBlackDefault.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            S.of(context).common_cancel,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.themePrimaryDefault
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: okEnabled
                          ? () => onOk?.call(controller.text.trim())
                          : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.themePrimaryDefault,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                              width: 1,
                              color: AppColors.themeBlackDefault.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: OutlinedButton(
                    //     onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    //     child: Text(cancelLabel),
                    //   ),
                    // ),
                    // const SizedBox(width: 10),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: okEnabled
                    //         ? () => onOk?.call(controller.text.trim())
                    //         : null,
                    //     child: Text(okLabel),
                    //   ),
                    // ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}