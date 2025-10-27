import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

import '../../../core/commons/app_colors.dart';
import '../../../core/commons/screen_size.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.imgTopBanner),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteColor,
                      ),
                      child: SvgPicture.asset(AppAssets.appLogo)
                  ),
                ),
              )),
            Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.colorPrimary50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30,),
                      Text("Xin chào!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeBlackDefault
                        ),),
                      Text("Nodo User",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.themeBlackDefault
                        ),)
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
