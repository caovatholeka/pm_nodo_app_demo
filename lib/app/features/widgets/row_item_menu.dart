import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';

class RowItemMenu extends StatelessWidget {
  final VoidCallback callback;
  final String mainText;
  final String? value;
  final bool? showPrefix;
  final TextStyle? textStyle;

  const RowItemMenu({
    super.key,
    required this.callback,
    required this.mainText,
    this.value,
    this.showPrefix = false,
    this.textStyle
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              mainText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.themeBlackDefault,
              ),
            ),
          ),

          (showPrefix ?? false) ? InkWell(
            onTap: callback,
            child: SizedBox(width: 36,height: 36,
              child: Icon(Icons.arrow_forward_ios,size: 20,color: AppColors.themeBlackDefault,),
            ),
          ) :
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: callback,
              child: Text(
                value ?? "",
                style: textStyle ?? TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.themeBlackDefault
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.right,
              ),
            ),
          )
        ],
      ),
    );
  }
}