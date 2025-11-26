import 'package:flutter/material.dart';
import '../../core/commons/app_colors.dart';
import 'loading_indicator.dart';

enum PrimaryButtonType {
  primary,
  secondary,
}

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    this.callback,
    required this.mainText,
    this.enable = true,
    this.isLoading = false,
    this.buttonWidth,
    this.borderRadius,
    this.style,
    this.type = PrimaryButtonType.primary,
  });

  final VoidCallback? callback;
  final String mainText;
  final bool enable;
  final double? buttonWidth;
  final double? borderRadius;
  final TextStyle? style;
  final PrimaryButtonType type;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = type == PrimaryButtonType.primary;

    final bool canPress = enable && !isLoading;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius ?? 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
        onTap: canPress ? callback : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: buttonWidth ?? double.infinity,
          decoration: BoxDecoration(
            color: isPrimary
                ? (canPress
                    ? AppColors.themePrimaryDefault
                    : AppColors.bgGray.withValues(alpha: 0.6))
                : Colors.white,
            borderRadius: BorderRadius.circular(borderRadius ?? 6),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFF2F64CC).withOpacity(0.4)
                  : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF3C7EFF).withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? LoadingIndicatorWidget(color: Colors.white)
                : Text(
                    mainText,
                    style: style ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? Colors.white
                              : AppColors.textPrimaryDefault,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
