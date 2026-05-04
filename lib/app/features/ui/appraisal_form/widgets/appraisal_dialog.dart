import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class AppraisalDialogResult {
  final int? suggestId;
  final String note;

  const AppraisalDialogResult({this.suggestId, required this.note});
}

class AppraisalDialog extends StatefulWidget {
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

  const AppraisalDialog({
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
    final controller = TextEditingController(text: initialNote ?? '');

    try {
      return await showDialog<AppraisalDialogResult>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder:
            (_) => AppraisalDialog(
              suggestId: suggestId,
              departmentName: departmentName,
              title: fixedTitle,
              hintText: fixedHintText,
              confirmText: fixedConfirmText,
              cancelText: fixedCancelText,
              controller: controller,
            ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  State<AppraisalDialog> createState() => _AppraisalDialogState();
}

class _AppraisalDialogState extends State<AppraisalDialog> {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          AppAssets.icFlag,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4B5563),
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
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppraisalDialog.fixedTitle,
                    style: TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppraisalDialog.fixedDepartmentName,
                    style: TextStyle(
                      fontFamily: AppConfig.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                      color: Color(0xFF5B6472),
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
                      color: Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      hintText: AppraisalDialog.fixedHintText,
                      hintStyle: const TextStyle(
                        fontFamily: AppConfig.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B93A1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7DDE6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD7DDE6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0A84FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: PrimaryButton(
                      mainText: AppraisalDialog.fixedConfirmText,
                      enable: _canSubmit,
                      isLoading: widget.isLoading,
                      borderRadius: 10,
                      style: const TextStyle(
                        fontFamily: AppConfig.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      callback: _handleConfirm,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: PrimaryButton(
                      mainText: AppraisalDialog.fixedCancelText,
                      type: PrimaryButtonType.secondary,
                      enable: widget.isLoading == false,
                      borderRadius: 10,
                      callback: _handleCancel,
                      style: const TextStyle(
                        fontFamily: AppConfig.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424B57),
                      ),
                    ),
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
