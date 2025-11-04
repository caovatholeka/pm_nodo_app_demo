import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/app_config.dart';
import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';


  class InputTextField extends StatefulWidget {
    final String title;
    final String hintText;
    final String? initialValue;
    final String? suffixIcon;
    final Widget? prefixWidget;
    final int? maxLength;
    final TextInputType? inputType;
    final TextEditingController? controller;
    final FocusNode? focusNode;
    final bool? readOnly;
    final bool? enable;
    final bool? disableTitle;
    final bool isRequiredField;
    final VoidCallback? callback;
    final int? maxLine;
    final VoidCallback? onEditingComplete;
    final ValueChanged<String>? onSubmited;
    final String? Function(String?)? validator;
    final ValueChanged<String>? onChange;
    final bool? bgrColor;
    final TextStyle? style;
    final bool? isObscured;
    final VoidCallback? onSuffixAction;

    const InputTextField({
      super.key,
      required this.title,
      required this.hintText,
      required this.isRequiredField,
      this.validator,
      this.initialValue,
      this.enable,
      this.readOnly,
      this.controller,
      this.suffixIcon,
      this.focusNode,
      this.prefixWidget,
      this.maxLength,
      this.inputType,
      this.maxLine,
      this.callback,
      this.onEditingComplete,
      this.onSubmited,
      this.disableTitle,
      this.onChange,
      this.bgrColor,
      this.style,
      this.isObscured,
      this.onSuffixAction,
    });

    @override
    State<InputTextField> createState() => _InputTextFieldState();
  }

  class _InputTextFieldState extends State<InputTextField> {
    @override
    Widget build(BuildContext context) {
      assert(!(widget.controller != null && widget.initialValue != null),
      'Provide either controller OR initialValue, not both.');

    final fillColor = (widget.enable == true || widget.bgrColor == true)
        ? Colors.white
        : AppColors.gray;

      final baseBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(width: 1, color: Colors.black.withValues(alpha: 0.1)),
      );

      final errorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Colors.red),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.disableTitle != true) ...[
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                if (widget.isRequiredField)
                  SvgPicture.asset(AppAssets.starRating),
              ],
            ),
            const SizedBox(height: 4),
          ],

          //
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              initialValue: widget.controller == null ? widget.initialValue : null,
              cursorHeight: 20,
              textAlignVertical: TextAlignVertical.center,
              enabled: widget.enable,
              validator: widget.validator,
              keyboardType: widget.inputType,
              onChanged: widget.onChange,
              onTap: (widget.enable == true || (widget.readOnly ?? false)) ? widget.callback : null,
              readOnly: widget.readOnly ?? false,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onSubmited,
              obscureText: widget.isObscured ?? false,
              style: widget.style ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray,
                  ),
              maxLines: widget.maxLine ?? 1,
              maxLength: widget.maxLength,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: InputDecoration(
                contentPadding: (widget.maxLine ?? 1) > 1
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintText: widget.hintText,
                counterText: "",
                filled: true,
                fillColor: fillColor,

                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  height: 1.0,
                  color: Color.fromRGBO(16, 16, 18, 0.4),
                ),

                prefixIcon: widget.prefixWidget != null
                    ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: widget.prefixWidget,
                ) : null,

                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

                suffixIcon: widget.suffixIcon != null
                    ? InkWell(
                  onTap: widget.onSuffixAction ?? widget.callback,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, left: 4),
                    child: SvgPicture.asset(
                      widget.suffixIcon!,
                      width: 14,
                      color: const Color(0xff666666),
                    ),
                  ),
                )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 16, minHeight: 16),

                border: baseBorder,
                enabledBorder: baseBorder,
                focusedBorder: baseBorder.copyWith(
                  borderSide: BorderSide(width: 1, color: Colors.black.withValues(alpha: 0.2)),
                ),
                errorBorder: errorBorder,
                focusedErrorBorder: errorBorder,

                errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
                errorMaxLines: 2,
              ),
            ),
          ),
        ],
      );
    }
  }
