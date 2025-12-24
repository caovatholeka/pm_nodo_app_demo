import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<TextInputFormatter>? inputFormatters;
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
  final bool isPasswordField;

  const InputTextField({
    super.key,
    required this.title,
    required this.hintText,
    required this.isRequiredField,
    this.validator,
    this.initialValue,
    this.enable = true,
    this.readOnly,
    this.controller,
    this.suffixIcon,
    this.focusNode,
    this.prefixWidget,
    this.maxLength,
    this.inputType,
    this.inputFormatters,
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
    this.isPasswordField = false,
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPasswordField ? true : (widget.isObscured ?? false);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !(widget.controller != null && widget.initialValue != null),
      'Provide either controller OR initialValue, not both.',
    );

    final fillColor =
        (widget.enable == true || widget.bgrColor == true)
            ? Colors.white
            : AppColors.lineGray50;

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 1, color: Colors.black.withAlpha(25)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (widget.isRequiredField)
                SvgPicture.asset(AppAssets.starRating),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            initialValue:
                widget.controller == null ? widget.initialValue : null,
            enabled: widget.enable,
            validator: widget.validator,
            keyboardType: widget.inputType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChange,
            onTap:
                (widget.enable == true || (widget.readOnly ?? false))
                    ? widget.callback
                    : null,
            readOnly: widget.readOnly ?? false,
            onEditingComplete: widget.onEditingComplete,
            onFieldSubmitted: widget.onSubmited,
            obscureText:
                widget.isPasswordField
                    ? _obscure
                    : (widget.isObscured ?? false),
            style:
                widget.style ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray,
                ),
            maxLines: widget.maxLine ?? 1,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              contentPadding:
                  (widget.maxLine ?? 1) > 1
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                      : const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
              hintText: widget.hintText,
              counterText: "",
              filled: true,
              fillColor: fillColor,
              prefixIcon: widget.prefixWidget,
              suffixIcon:
                  widget.isPasswordField
                      ? InkWell(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SvgPicture.asset(
                              _obscure
                                  ? AppAssets.icEyeClose
                                  : AppAssets.icEyeVisible,
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      )
                      : null,

              border: baseBorder,
              enabledBorder: baseBorder,
              focusedBorder: baseBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
            ),
          ),
        ),
      ],
    );
  }
}
