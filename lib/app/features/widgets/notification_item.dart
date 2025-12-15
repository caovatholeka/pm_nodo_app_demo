import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'notification_detail_dialog.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity item;

  const NotificationItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !(item.isSeen ?? false);

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color.fromARGB(255, 241, 240, 240),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  timeAgo(item.createDate, context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              item.content ?? "",
              style: TextStyle(
                fontSize: 13.2,
                height: 1.35,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
