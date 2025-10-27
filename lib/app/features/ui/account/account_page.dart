import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/commons/app_assets.dart';
import '../../../core/commons/app_colors.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.imgBg2),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 68,),
              _headerWidget,
            ],
          ),
        ),
      ),
    );
  }

  get _headerWidget{
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(4),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor,
            ),
            child: Center(child: SvgPicture.asset(AppAssets.icBack,color: AppColors.themeBlackDefault,width: 16,))
        ),
        // Spacer(),
        const SizedBox(width: 100,),
        Text("Cá nhân",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor
          ),
        )
      ],
    );
  }

  get _accountInfo {
    return Stack(
      children: [
        Positioned(
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ))
      ],
    );
  }
}
