import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/send_suggestion_param.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của `WorkQualitySuggestionCard`
/// (lib/app/features/ui/dashboard/widgets/work_quality_suggestion_card.dart).
/// Cùng contract: gửi góp ý qua [DashboardCubit.submitImprovemnt], lắng nghe
/// `suggestionStatus` để hiện snackbar + reset trạng thái.
class WorkQualitySuggestionCardV2 extends StatefulWidget {
  final String month;

  const WorkQualitySuggestionCardV2({super.key, required this.month});

  @override
  State<WorkQualitySuggestionCardV2> createState() =>
      _WorkQualitySuggestionCardV2State();
}

class _WorkQualitySuggestionCardV2State
    extends State<WorkQualitySuggestionCardV2> {
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
          SendSuggestionParam(month: widget.month, message: message),
        );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) =>
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.appraisal_suggestion_title, style: AppTokensV2.section),
              Text(
                s.appraisal_optional,
                style: AppTokensV2.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTokensV2.surfaceStrong,
              border: Border.all(color: AppTokensV2.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              style: AppTokensV2.body,
              cursorColor: AppTokensV2.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: s.appraisal_suggestion_hint_long,
                hintStyle: AppTokensV2.caption,
              ),
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DashboardCubit, DashboardState>(
            buildWhen: (previous, current) =>
                previous.suggestionStatus != current.suggestionStatus,
            builder: (context, state) {
              return _SubmitButtonV2(
                label: s.confirm,
                enabled: _controller.text.trim().isNotEmpty,
                isLoading: state.suggestionStatus == LoadStatus.LOADING,
                onTap: _submit,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubmitButtonV2 extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButtonV2({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;

    return GestureDetector(
      onTap: active
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active ? AppTokensV2.accentGradient : null,
          color: active ? null : AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(15),
          border: active ? null : Border.all(color: AppTokensV2.border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTokensV2.glow,
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.2),
              )
            : Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppTokensV2.fgMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
