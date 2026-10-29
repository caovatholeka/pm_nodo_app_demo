import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/generated/l10n.dart';

class ErrorListWidget extends StatelessWidget {
  /// null → "Không thể kết nối tới Server" theo ngôn ngữ hiện tại.
  final String? text;
  final RefreshCallback onRefresh;
  final double? height;

  const ErrorListWidget({super.key, this.text, required this.onRefresh, this.height});

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
                  text ?? S.of(context).common_cannot_connect_server,
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