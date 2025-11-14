import 'package:flutter/material.dart';
import '../../core/commons/app_colors.dart';
import 'loading_indicator.dart';

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
  });
  final VoidCallback? callback;
  final String mainText;
  final bool enable;
  final double? buttonWidth;
  final double? borderRadius;
  final TextStyle? style;
  bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enable ? callback : (){},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: buttonWidth ?? double.infinity,
        decoration: BoxDecoration(
          color: enable 
          ? AppColors.themePrimaryDefault
          : Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? 6),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3C7EFF),
            )
          ],
          border: Border.all(
            color: Color(0xFF2F64CC).withValues(alpha: 0.4),
            width: 1
          )
        ),
        child: Center(
          child: isLoading ? LoadingIndicatorWidget(color: Colors.white) :
            Text(
            mainText,
            style: style ?? TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
               color: enable
               ?  Colors.white
               : AppColors.themePrimaryDefault,
            ),
          ),
        ),
      ),
    );
  }
}
