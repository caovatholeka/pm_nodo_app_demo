import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

enum ContactType { phone, email }

class ContactActionText extends StatelessWidget {
  final String value;
  final ContactType type;
  final TextStyle? style;

  const ContactActionText({
    super.key,
    required this.value,
    required this.type,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showContactSheet(context),
      child: Text(
        value,
        style: style ??
            const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isPhone = type == ContactType.phone;
        final s = S.of(ctx);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isPhone ? s.common_phone_number : 'Email',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ),

              const Divider(),

              // Copy
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(isPhone ? s.common_copy_phone_number : 'Copy email'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isPhone
                            ? s.common_phone_number_copied
                            : s.common_email_copied,
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),

              // Gọi / Gửi email
              ListTile(
                leading: Icon(isPhone ? Icons.phone : Icons.email),
                title: Text(isPhone ? s.common_call_this_number : s.common_send_email_to_address),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  if (isPhone) {
                    await _callPhone(context);
                  } else {
                    await _sendEmail(context);
                  }
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _callPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: value);
    final errorText = S.of(context).common_cannot_make_call;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: value,
      // query: 'subject=Hello&body=Xin chào',
    );
    final errorText = S.of(context).common_cannot_open_email_app;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    }
  }
}
