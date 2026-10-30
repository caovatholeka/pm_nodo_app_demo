import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/input_limits.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/input_counter_v2.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../ui/appraisal_form/widgets/hr_dialog.dart' show HrDialogResult;

/// Bản tối (v2) của [HrDialog]. Cùng static API `show(...)` và cùng kiểu
/// kết quả [HrDialogResult] (import lại từ bản gốc, không tạo state/type mới)
/// để orchestrator (vẫn gọi `HrDialog.show(...)` cho bản cũ) không cần đổi gì
/// khi bản v2 được nối dây ở task khác — chỉ đổi màu/kiểu chữ sang tông tối.
class HrDialogV2 extends StatefulWidget {
  // Để null → dùng chữ mặc định theo ngôn ngữ (l10n) khi build.
  final String? title;
  final String? departmentName;
  final String? hintText;
  final String? confirmText;
  final String? cancelText;
  final String? initialNote;
  final TextEditingController? controller;
  final bool isLoading;
  final bool autoCloseOnSubmit;
  final Future<void> Function(HrDialogResult result)? onSubmit;
  final VoidCallback? onClose;

  const HrDialogV2({
    super.key,
    this.title,
    this.departmentName,
    this.hintText,
    this.confirmText,
    this.cancelText,
    this.initialNote,
    this.controller,
    this.isLoading = false,
    this.autoCloseOnSubmit = true,
    this.onSubmit,
    this.onClose,
  });

  static Future<HrDialogResult?> show(
    BuildContext context, {
    String? title,
    String? departmentName,
    String? hintText,
    String? confirmText,
    String? cancelText,
    String? initialNote,
    bool barrierDismissible = true,
  }) async {
    return showDialog<HrDialogResult>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (_) => HrDialogV2(
            title: title,
            departmentName: departmentName,
            hintText: hintText,
            confirmText: confirmText,
            cancelText: cancelText,
            initialNote: initialNote,
          ),
    );
  }

  @override
  State<HrDialogV2> createState() => _HrDialogV2State();
}

class _HrDialogV2State extends State<HrDialogV2> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(bool isApproved) async {
    if (widget.isLoading) return;

    final result = HrDialogResult(
      note: _controller.text.trim(),
      isApproved: isApproved,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(result);
      if (!mounted || widget.autoCloseOnSubmit == false) return;
    }

    Navigator.of(context).pop(result);
  }

  void _handleClose() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = widget.title ?? s.v2_appraisal_opinion_proposal;
    final departmentName =
        widget.departmentName ?? s.v2_appraisal_hr_admin_department;
    final hintText = widget.hintText ?? s.v2_appraisal_hr_admin_opinion_hint;
    final confirmText = widget.confirmText ?? s.notifications_agree;
    final cancelText = widget.cancelText ?? s.deny;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: AppTokensV2.bgTop,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTokensV2.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTokensV2.surfaceStrong,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTokensV2.border),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.icFlag,
                      colorFilter: ColorFilter.mode(
                        AppTokensV2.fgSoft,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.isLoading ? null : _handleClose,
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 30,
                      color: AppTokensV2.fgMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppTokensV2.fg,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                departmentName,
                style: TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  color: AppTokensV2.fgMuted,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _controller,
                maxLines: 1,
                maxLength: InputLimits.appraisalNote,
                buildCounter: inputCounterV2(always: false),
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTokensV2.fg,
                ),
                cursorColor: AppTokensV2.accent,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontFamily: AppConfig.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTokensV2.fgMuted,
                  ),
                  filled: true,
                  fillColor: AppTokensV2.surfaceStrong,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTokensV2.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTokensV2.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTokensV2.accent),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _DialogButtonV2(
                label: confirmText,
                enabled: widget.isLoading == false,
                isLoading: widget.isLoading,
                isPrimary: true,
                onTap: () => _submit(true),
              ),
              const SizedBox(height: 14),
              _DialogButtonV2(
                label: cancelText,
                enabled: widget.isLoading == false,
                isLoading: false,
                isPrimary: false,
                onTap: () => _submit(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút dùng riêng cho dialog v2 — tái tạo đúng trạng thái enable/loading của
/// [PrimaryButton] gốc, chỉ đổi màu sắc sang tông tối.
class _DialogButtonV2 extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onTap;

  const _DialogButtonV2({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canPress = enabled && !isLoading;

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap:
              canPress
                  ? () {
                    HapticFeedback.selectionClick();
                    onTap();
                  }
                  : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: isPrimary && canPress ? AppTokensV2.accentGradient : null,
              color:
                  isPrimary
                      ? (canPress ? null : AppTokensV2.surfaceStrong)
                      : AppTokensV2.surfaceStrong,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPrimary ? Colors.transparent : AppTokensV2.border,
              ),
            ),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                      : Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppConfig.fontFamily,
                          fontSize: 16,
                          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                          color:
                              isPrimary
                                  ? Colors.white
                                  : AppTokensV2.fgSoft,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
