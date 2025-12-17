import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';

class FaceMaskWithWave extends StatelessWidget {
  const FaceMaskWithWave({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;

    final maskW = size.width * 0.70;
    final maskH = maskW * 1.18;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: maskW,
      height: maskH,
    );

    return Stack(
      children: [
        Positioned.fromRect(
          rect: rect,
          child: IgnorePointer(
            child: SvgPicture.asset(
              AppAssets.faceRecog,
              fit: BoxFit.fill,
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 88 + MediaQuery.of(context).padding.bottom,
          child: Column(
            children: [
              Text(
                s.check_in_hint2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                s.check_in_hint3,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
