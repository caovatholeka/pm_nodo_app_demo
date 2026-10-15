import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';

class FaceMaskWithWave extends StatelessWidget {
  /// Mặt đã nằm đúng khung, đúng tư thế → khung chuyển xanh
  final bool faceValid;

  const FaceMaskWithWave({super.key, this.faceValid = false});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.of(context).size;
    final paddingBottom = MediaQuery.of(context).padding.bottom;

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
              colorFilter: faceValid
                  ? const ColorFilter.mode(Color(0xFF34C759), BlendMode.srcIn)
                  : null,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 88 + paddingBottom,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.check_in_hint2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.check_in_hint3,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
