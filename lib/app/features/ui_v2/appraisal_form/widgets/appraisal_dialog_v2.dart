import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';

import '../../../ui/appraisal_form/widgets/appraisal_dialog.dart'
    show AppraisalDialogResult;

/// Bản tối (v2) của [AppraisalDialog]. Cùng static API `show(...)` và cùng
/// kiểu kết quả [AppraisalDialogResult] (import lại từ bản gốc, không tạo
/// type mới) để nơi gọi (kể cả bản cũ gọi `AppraisalDialog.show(...)`) không
/// phải đổi gì khi bản v2 được nối dây ở task khác — chỉ đổi màu/kiểu chữ
/// sang tông tối.
class AppraisalDialogV2 extends StatefulWidget {
  static const String fixedTitle = 'Ý kiến - Đề xuất';
  static const String fixedDepartmentName = 'Phòng hành chính nhân sự';
  static const String fixedHintText = 'Ý kiến của phòng hành chính nhân sự';
  static const String fixedConfirmText = 'Xác nhận';
  static const String fixedCancelText = 'Cancel';

  final int? suggestId;
  final String title;
  final String departmentName;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final String? initialNote;
  final TextEditingController? controller;
  final bool isLoading;
  final bool autoCloseOnConfirm;
  final Future<void> Function(AppraisalDialogResult result)? onConfirm;
  final VoidCallback? onCancel;

  const AppraisalDialogV2({
    super.key,
    this.suggestId,
    required this.departmentName,
    this.title = fixedTitle,
    this.hintText = fixedHintText,
    this.confirmText = fixedConfirmText,
    this.cancelText = fixedCancelText,
    this.initialNote,
    this.controller,
    this.isLoading = false,
    this.autoCloseOnConfirm = true,
    this.onConfirm,
    this.onCancel,
  });

  static Future<AppraisalDialogResult?> show(
    BuildContext context, {
    int? suggestId,
    required String departmentName,
    String title = fixedTitle,
    String? hintText,
    String? confirmText,
    String? cancelText,
    String? initialNote,
    bool barrierDismissible = true,
  }) async {
    return showDialog<AppraisalDialogResult>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (_) => AppraisalDialogV2(
            suggestId: suggestId,
            departmentName: departmentName,
            title: fixedTitle,
            hintText: fixedHintText,
            confirmText: fixedConfirmText,
            cancelText: fixedCancelText,
            initialNote: initialNote,
          ),
    );
  }

  @override
  State<AppraisalDialogV2> createState() => _AppraisalDialogV2State();
}

class _AppraisalDialogV2State extends State<AppraisalDialogV2> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  bool get _canSubmit =>
      _controller.text.trim().isNotEmpty && widget.isLoading == false;

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

  Future<void> _handleConfirm() async {
    if (!_canSubmit) return;

    final result = AppraisalDialogResult(
      suggestId: widget.suggestId,
      note: _controller.text.trim(),
    );

    if (widget.onConfirm != null) {
      await widget.onConfirm!(result);
      if (!mounted || widget.autoCloseOnConfirm == false) return;
    }

    Navigator.of(context).pop(result);
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, _, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTokensV2.surfaceStrong,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTokensV2.border),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.icFlag,
                          colorFilter: const ColorFilter.mode(
                            AppTokensV2.fgSoft,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.isLoading ? null : _handleCancel,
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: AppTokensV2.fgMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppraisalDialogV2.fixedTitle,
                    style: TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppTokensV2.fg,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppraisalDialogV2.fixedDepartmentName,
                    style: TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                      color: AppTokensV2.fgMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTokensV2.fg,
                    ),
                    cursorColor: AppTokensV2.accent,
                    decoration: InputDecoration(
                      hintText: AppraisalDialogV2.fixedHintText,
                      hintStyle: const TextStyle(
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
                        borderSide: const BorderSide(color: AppTokensV2.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTokensV2.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTokensV2.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogButtonV2(
                    label: AppraisalDialogV2.fixedConfirmText,
                    enabled: _canSubmit,
                    isLoading: widget.isLoading,
                    isPrimary: true,
                    height: 46,
                    onTap: _handleConfirm,
                  ),
                  const SizedBox(height: 10),
                  _DialogButtonV2(
                    label: AppraisalDialogV2.fixedCancelText,
                    enabled: widget.isLoading == false,
                    isLoading: false,
                    isPrimary: false,
                    height: 46,
                    onTap: _handleCancel,
                  ),
                ],
              );
            },
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
  final double height;
  final VoidCallback onTap;

  const _DialogButtonV2({
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.isPrimary,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canPress = enabled && !isLoading;

    return SizedBox(
      height: height,
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
                          color: isPrimary ? Colors.white : AppTokensV2.fgSoft,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
