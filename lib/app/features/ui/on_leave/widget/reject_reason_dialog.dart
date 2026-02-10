import 'package:flutter/material.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';

class RejectReasonDialog extends StatefulWidget {
  final String title;
  final String description;
  final String hintText;
  final ValueChanged<String> onConfirm;

  const RejectReasonDialog({
    super.key,
    required this.title,
    required this.description,
    required this.hintText,
    required this.onConfirm,
  });

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  void _submit() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorText = "Vui lòng nhập lý do";
      });
      return;
    }

    Navigator.pop(context);
    widget.onConfirm(text);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 16),

                InputTextField(
                  title: "Lý do",
                  hintText: widget.hintText,
                  isRequiredField: true,
                  controller: _controller,
                  maxLine: 3,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        mainText: "Huỷ",
                        type: PrimaryButtonType.secondary,
                        callback: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        mainText: "Từ chối",
                        type: PrimaryButtonType.primary,
                        callback: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
