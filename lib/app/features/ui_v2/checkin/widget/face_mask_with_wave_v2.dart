import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của `FaceMaskWithWave` gốc
/// (lib/app/features/ui/checkin/widget/mask_with_wave.dart).
///
/// CHỈ đổi màu/kiểu chữ theo [AppTokensV2] — hình học (kích thước khung,
/// vị trí) giữ nguyên y hệt bản gốc, cùng tham số constructor (không có
/// tham số nào, chỉ có `key`).
///
/// Lưu ý: đây là lớp phủ trên preview camera trực tiếp (nội dung nền thay
/// đổi liên tục, không phải nền app), nên dùng lớp phủ tối đủ đục
/// (`AppTokensV2.bgDeep` alpha cao) để đảm bảo chữ luôn đọc được, thay vì
/// `AppTokensV2.surfaceStrong` (~9% alpha) vốn thiết kế cho nền app cố định.
class FaceMaskWithWaveV2 extends StatelessWidget {
  const FaceMaskWithWaveV2({super.key});

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
            child: SvgPicture.asset(AppAssets.faceRecog, fit: BoxFit.fill),
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
                  color: AppTokensV2.bgDeep.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTokensV2.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.check_in_hint2,
                      style: AppTokensV2.section,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.check_in_hint3,
                      style: AppTokensV2.captionStrong.copyWith(height: 1.35),
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
