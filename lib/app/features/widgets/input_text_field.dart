import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/app_config.dart';
import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';

class InputTextField extends StatefulWidget {
  final String? title;
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
  final Color? fillBgColor;

  const InputTextField({
    super.key,
    this.title,
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
    this.fillBgColor,
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool _obscure = false;
  TextEditingController? _internalController;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPasswordField ? true : (widget.isObscured ?? false);
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void didUpdateWidget(covariant InputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }

      if (widget.controller == null) {
        _internalController = TextEditingController(text: widget.initialValue);
      }
    }

    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        _internalController?.text != (widget.initialValue ?? '')) {
      _internalController?.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
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
      borderSide: BorderSide(
        width: 1,
        color: const Color.fromARGB(255, 133, 133, 133).withAlpha(25),
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(width: 1, color: Colors.red),
    );

    final showTitle =
        widget.disableTitle != true &&
        widget.title != null &&
        widget.title!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  widget.title!,
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
                SvgPicture.asset(
                  AppAssets.starRating,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: TextFormField(
            controller: _effectiveController,
            focusNode: widget.focusNode,
            initialValue: null,
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
                  color: Colors.black,
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
              hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFFBDBDBD),
              ),
              counterText: "",
              filled: true,
              fillColor: widget.fillBgColor ?? fillColor,
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
                      : widget.suffixIcon != null
                      ? InkWell(
                        onTap: widget.onSuffixAction ?? widget.callback,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SvgPicture.asset(
                              widget.suffixIcon!,
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
