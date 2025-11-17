import 'dart:ui';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;

  final String? confirmText;
  final String? cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final String iconPath;   
  final bool success;  

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.iconPath,    
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.success = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color btnColor =
        success ? const Color(0xFF0066FF) : const Color(0xFFE53935);

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),

        Center(
          child: TweenAnimationBuilder(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),

            child: Container(
              width: 352,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.20),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Image.asset(
                        iconPath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        if (onConfirm != null) {
                          onConfirm!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        confirmText ?? "OK",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelText ?? "Hủy bỏ",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
