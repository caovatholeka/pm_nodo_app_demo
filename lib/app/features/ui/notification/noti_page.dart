import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';
import '../../../core/commons/screen_size.dart';
import '../../navigation/bottom_navigation.dart';
import 'noti_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotiState notiState;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    notiState = NotiState();
  }

  void _goBack() {
    Navigator.push(context, 
    MaterialPageRoute(builder: (context) => BottomNavigation())
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.imgBg2),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.04,
                vertical: screen.height * 0.015,
        ),
               child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
              GestureDetector(
                 onTap: () {
                  _goBack();
               },
                child: Image.asset(
                AppAssets.ic_arrowB,
                 width: 28,
              ),
            ),

             const Text(
             "Thông báo",
             style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Colors.white,
            ),
          ),
      GestureDetector(
        onTap: () {
          print("No Event Yet");
        },
        child: Image.asset(
          AppAssets.ic_read_all,
          width: 36,
          height: 36,
        ),
      ),
    ],
  ),
),
              Container(
                margin: EdgeInsets.symmetric(vertical: screen.height * 0.01),
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTab("Tất cả", 0),
                    _buildTab("Chung", 1),
                    _buildTab("Cá nhân", 2),
                    _buildTab("Chưa đọc", 3),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.all(screen.width * 0.01),
                  padding: EdgeInsets.all(screen.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView(
                    children: [
                      const Text("Hôm nay",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: screen.height * 0.01),
                      ...notiState.today.map(_buildNotiItem),

                      SizedBox(height: screen.height * 0.025),
                      const Text("Hôm qua",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: screen.height * 0.01),
                      ...notiState.yesterday.map(_buildNotiItem),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }
  Widget _buildNotiItem(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: item.isUnread ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  child: Image.asset(item.imagepath, fit: BoxFit.contain),
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
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subtitle,
                          height: 1.4,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.isUnread)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.newNotification,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
