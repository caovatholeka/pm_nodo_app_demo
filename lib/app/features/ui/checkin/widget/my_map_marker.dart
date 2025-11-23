import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/check_in_info_entity.dart';

import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/app_shadow.dart';

class MyMapMarker extends StatelessWidget {
  CheckInInfoEntity? infoEntity;

  MyMapMarker({
    Key? key,
    this.infoEntity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 3),
      height: 28,
      width: 28,
      color: Colors.transparent,
      child: SvgPicture.asset(AppAssets.icCheckinPlace,width: 24,height: 28),
      // decoration: BoxDecoration(
      //   color: AppColors.themePrimaryDefault,
      //   border: Border.all(
      //       color: AppColors.whiteColor,
      //       width: 1.5
      //   ),
      //   boxShadow: AppShadow.bottomShadow,
      // ),
      // child: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     SvgPicture.asset(AppAssets.icBuildingLine,width: 14,height: 14,).paddingOnly(right: 4),
      //     Text(
      //       " 0.1 km", // khoảng cách tới vị trí hiện tại của user
      //       style: TextStyle(
      //         fontStyle: FontStyle.normal,
      //         fontSize: 11,
      //         fontWeight: FontWeight.w600,
      //         color: AppColors.whiteColor,
      //       ),
      //       textAlign: TextAlign.center,
      //     )
      //   ],
      // )
    );
  }
}