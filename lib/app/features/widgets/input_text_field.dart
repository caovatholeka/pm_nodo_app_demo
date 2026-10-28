import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/app_config.dart';
import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';
import '../../core/theme_v2/app_tokens_v2.dart';

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

  /// Kiểu giao diện v2 (theo theme sáng/tối): tiêu đề, dấu *, viền, chữ gợi ý và icon
  /// dùng màu AppTokensV2 như các ô nhập khác của v2. Mặc định false = giữ kiểu cũ (v1).
  final bool v2Style;

  /// Bộ đếm ký tự khi có [maxLength] (vd `inputCounterV2()`); null = ẩn bộ đếm như cũ.
  final InputCounterWidgetBuilder? buildCounter;

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
    this.v2Style = false,
    this.buildCounter,
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

    final v2 = widget.v2Style;
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(v2 ? AppTokensV2.radiusSm : 10),
      borderSide: BorderSide(
        width: 1,
        color: v2
            ? AppTokensV2.border
            : const Color.fromARGB(255, 133, 133, 133).withAlpha(25),
      ),
    );
    // Icon (lịch, mắt mật khẩu): v2 tô theo màu chữ phụ để nổi trên nền tối.
    final ColorFilter? iconFilter =
        v2 ? ColorFilter.mode(AppTokensV2.fgSoft, BlendMode.srcIn) : null;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    widget.title!,
                    style: v2
                        ? AppTokensV2.caption
                        : const TextStyle(
                            fontFamily: AppConfig.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (widget.isRequiredField && v2)
                Text('*',
                    style: TextStyle(color: AppTokensV2.danger, fontSize: 12))
              else if (widget.isRequiredField)
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
                (v2
                    ? TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTokensV2.fg,
                      )
                    : const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      )),
            cursorColor: v2 ? AppTokensV2.accent : null,
            maxLines: widget.maxLine ?? 1,
            maxLength: widget.maxLength,
            buildCounter: widget.buildCounter,
            decoration: InputDecoration(
              contentPadding:
                  (widget.maxLine ?? 1) > 1
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                      : const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: v2 ? AppTokensV2.fgMuted : const Color(0xFFBDBDBD),
              ),
              // Có buildCounter thì để nó vẽ bộ đếm; không thì ẩn như cũ.
              counterText: widget.buildCounter == null ? "" : null,
              filled: true,
              fillColor: widget.fillBgColor ??
                  (v2 ? AppTokensV2.surfaceStrong : fillColor),
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
                              colorFilter: iconFilter,
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
                              colorFilter: iconFilter,
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
