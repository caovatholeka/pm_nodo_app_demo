import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/config/app_config.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class HrDialogResult {
  final String note;
  final bool isApproved;

  const HrDialogResult({required this.note, required this.isApproved});
}

class HrDialog extends StatefulWidget {
  static const String fixedTitle = 'Ý kiến - Đề xuất';
  static const String fixedDepartmentName = 'Phòng hành chính nhân sự';
  static const String fixedHintText = 'Ý kiến của Phòng hành chính nhân sự';
  static const String fixedConfirmText = 'Đồng ý';
  static const String fixedCancelText = 'Từ chối';

  final String title;
  final String departmentName;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final String? initialNote;
  final TextEditingController? controller;
  final bool isLoading;
  final bool autoCloseOnSubmit;
  final Future<void> Function(HrDialogResult result)? onSubmit;
  final VoidCallback? onClose;

  const HrDialog({
    super.key,
    this.title = fixedTitle,
    this.departmentName = fixedDepartmentName,
    this.hintText = fixedHintText,
    this.confirmText = fixedConfirmText,
    this.cancelText = fixedCancelText,
    this.initialNote,
    this.controller,
    this.isLoading = false,
    this.autoCloseOnSubmit = true,
    this.onSubmit,
    this.onClose,
  });

  static Future<HrDialogResult?> show(
    BuildContext context, {
    String title = fixedTitle,
    String departmentName = fixedDepartmentName,
    String hintText = fixedHintText,
    String confirmText = fixedConfirmText,
    String cancelText = fixedCancelText,
    String? initialNote,
    bool barrierDismissible = true,
  }) async {
    return showDialog<HrDialogResult>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (_) => HrDialog(
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
  State<HrDialog> createState() => _HrDialogState();
}

class _HrDialogState extends State<HrDialog> {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
                    onPressed: widget.isLoading ? null : _handleClose,
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
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.departmentName,
                style: const TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  color: Color(0xFF5B6472),
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _controller,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontFamily: AppConfig.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1F2937),
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
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
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryButton(
                  mainText: widget.confirmText,
                  enable: widget.isLoading == false,
                  isLoading: widget.isLoading,
                  borderRadius: 10,
                  style: const TextStyle(
                    fontFamily: AppConfig.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  callback: () => _submit(true),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: PrimaryButton(
                  mainText: widget.cancelText,
                  type: PrimaryButtonType.secondary,
                  enable: widget.isLoading == false,
                  borderRadius: 10,
                  callback: () => _submit(false),
                  style: const TextStyle(
                    fontFamily: AppConfig.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424B57),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
