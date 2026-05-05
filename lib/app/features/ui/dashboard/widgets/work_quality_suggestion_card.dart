import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/generated/l10n.dart';

class WorkQualitySuggestionCard extends StatefulWidget {
  final String month;

  const WorkQualitySuggestionCard({
    super.key,
    required this.month,
  });

  @override
  State<WorkQualitySuggestionCard> createState() =>
      _WorkQualitySuggestionCardState();
}

class _WorkQualitySuggestionCardState extends State<WorkQualitySuggestionCard> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _submit() {
    final s = S.of(context);
    final message = _controller.text.trim();
    if (message.isEmpty) {
      AppSnackBar.showWarning(
        title: s.warning,
        message: s.appraisal_suggestion_empty,
      );
      return;
    }

    context.read<DashboardCubit>().submitImprovemnt(
      SendSuggestionParam(
        month: widget.month,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<DashboardCubit, DashboardState>(
      listenWhen:
          (previous, current) =>
              previous.suggestionStatus != current.suggestionStatus,
      listener: (context, state) {
        if (state.suggestionStatus == LoadStatus.SUCCESS) {
          _controller.clear();
          AppSnackBar.showInfo(
            title: s.success,
            message: s.appraisal_suggestion_success,
          );
          context.read<DashboardCubit>().resetSuggestionStatus();
        }

        if (state.suggestionStatus == LoadStatus.FAILURE) {
          AppSnackBar.showError(
            title: s.error,
            message: state.errorMessage ?? s.appraisal_suggestion_failed,
          );
          context.read<DashboardCubit>().resetSuggestionStatus();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.appraisal_suggestion_title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray600,
                  ),
                ),
                Text(
                  s.appraisal_optional,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InputTextField(
              controller: _controller,
              hintText: s.appraisal_suggestion_hint_long,
              isRequiredField: false,
              disableTitle: true,
              maxLine: 4,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textGray600,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<DashboardCubit, DashboardState>(
              buildWhen:
                  (previous, current) =>
                      previous.suggestionStatus != current.suggestionStatus,
              builder: (context, state) {
                return PrimaryButton(
                  mainText: s.confirm,
                  enable: _controller.text.trim().isNotEmpty,
                  isLoading: state.suggestionStatus == LoadStatus.LOADING,
                  callback: _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
