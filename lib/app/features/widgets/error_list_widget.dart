import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class ErrorListWidget extends StatelessWidget {
  final String text;
  final RefreshCallback onRefresh;
  final double? height;

  const ErrorListWidget({super.key, this.text = 'Không thể kết nối tới Server', required this.onRefresh, this.height});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return SizedBox(
              height:height ?? 100,
              width: double.infinity,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGray600
                  ),
                ),
              ),
            );
          },
          itemCount: 1,
        ));
  }
}