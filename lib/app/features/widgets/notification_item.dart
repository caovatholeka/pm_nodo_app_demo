import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'notification_detail_dialog.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity item;

  const NotificationItem({super.key, required this.item});

  bool get _isUnread => !(item.isSeen ?? false);

  String get _avatarText {
    final name = item.username ?? item.name ?? item.title ?? "";
    if (name.trim().isEmpty) return "";
    return name.trim().substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _avatarColor(String seed) {
    final colors = [
      const Color(0xFFFFB300),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
    ];
    return colors[seed.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => NotificationDetailDialog(item: item),
        );

        context.read<NotiCubit>().markRead(
              markAll: false,
              id: item.id,
            );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isUnread ? const Color(0xFFF1F6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(),

                if (_isUnread)
                  Positioned(
                    left: -14,
                    top: 18,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A73E8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            children: _buildTitleSpan(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeAgo(item.createDate, context),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.content ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final text = _avatarText;

    return CircleAvatar(
      radius: 20,
      backgroundColor:
          text.isNotEmpty ? _avatarColor(text) : const Color(0xFFFDECEA),
      child: text.isNotEmpty
          ? Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            )
          : const Icon(
              Icons.notifications_none,
              color: Colors.redAccent,
              size: 20,
            ),
    );
  }

  List<TextSpan> _buildTitleSpan() {
    final title = item.title ?? "";
    final parts = title.split(" ");

    if (parts.length > 1) {
      return [
        TextSpan(
          text: "${parts.first} ",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: parts.sublist(1).join(" "),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ];
    }

    return [
      TextSpan(text: title),
    ];
  }
}



