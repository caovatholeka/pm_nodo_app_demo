import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
// import 'package:pm_app/app/core/values/app_assets.dart'; // Import file AppAssets của bạn
import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'notification_detail_dialog.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity item;

  const NotificationItem({super.key, required this.item});

  bool get _isUnread => !(item.isSeen ?? false);

  Map<String, dynamic> _getIconData() {
    final title = (item.title ?? "").toLowerCase();

    if (title.contains("điểm danh") || title.contains("checkin")) {
      return {
        'icon': AppAssets.icCheckInNoti,
        'color': const Color(0xFFE8F5E9),
        'iconColor': Colors.green,
      };
    } else if (title.contains("nhân viên") || title.contains("nghỉ")) {
      return {
        'icon': AppAssets.icEmployeeNoti,
        'color': const Color(0xFFE3F2FD),
        'iconColor': Colors.blue,
      };
    } else if (title.contains("đơn") || title.contains("phiếu")) {
      return {
        'icon': AppAssets.icPaperNoti,
        'color': const Color(0xFFFFF3E0),
        'iconColor': Colors.orange,
      };
    }

    // Mặc định là chuông thông báo
    return {
      'icon': AppAssets.icBellNoti,
      'color': const Color(0xFFFDECEA),
      'iconColor': Colors.redAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => NotificationDetailDialog(item: item),
        );

        context.read<NotiCubit>().markRead(markAll: false, id: item.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: _isUnread ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                width: 60,
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (_isUnread)
                      Positioned(
                        left: -5,
                        top: 7,
                        bottom: 1,
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF007BFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2,right: 5),
                        child: _buildAvatarIcon(),
                      ),
                    ),
                  ],
                ),
              ),
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
                        child: Text(
                          item.title ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _isUnread
                                    ? const Color(0xFF2196F3)
                                    : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo(item.createDate, context),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.blueGrey.shade600,
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

  Widget _buildAvatarIcon() {
    final data = _getIconData();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: data['color']),
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset(data['icon'], color: data['iconColor']),
    );
  }
}
