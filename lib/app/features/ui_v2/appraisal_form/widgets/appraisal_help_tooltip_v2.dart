import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:super_tooltip/super_tooltip.dart';

/// Bản tối (v2) của [AppraisalHelpTooltip]
/// (`lib/app/features/ui/appraisal_form/widgets/appraisal_help_tooltip.dart`).
/// Cùng API (`message`, `autoShow`) và cùng hành vi tự-hiện/tự-ẩn sau 3s —
/// chỉ đổi màu bong bóng tooltip và icon sang tông tối.
class AppraisalHelpTooltipV2 extends StatefulWidget {
  final String message;
  final bool autoShow;

  const AppraisalHelpTooltipV2({
    super.key,
    required this.message,
    this.autoShow = false,
  });

  @override
  State<AppraisalHelpTooltipV2> createState() =>
      _AppraisalHelpTooltipV2State();
}

class _AppraisalHelpTooltipV2State extends State<AppraisalHelpTooltipV2> {
  final SuperTooltipController _controller = SuperTooltipController();
  Timer? _hideTimer;
  bool _didAutoShow = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoShowIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AppraisalHelpTooltipV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoShow && !_didAutoShow) {
      _scheduleAutoShowIfNeeded();
    }
  }

  void _scheduleAutoShowIfNeeded() {
    if (!widget.autoShow || _didAutoShow) return;
    _didAutoShow = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _controller.showTooltip();
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _controller.hideTooltip();
        }
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      controller: _controller,
      barrierConfig: const BarrierConfiguration(show: false),
      interactionConfig: const InteractionConfiguration(
        toggleOnTap: true,
        showOnTap: true,
      ),
      positionConfig: const PositionConfiguration(
        preferredDirection: TooltipDirection.down,
      ),
      style: const TooltipStyle(
        backgroundColor: AppTokensV2.bgTop,
        borderColor: AppTokensV2.border,
        borderWidth: 1,
        borderRadius: 12,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          widget.message,
          style: const TextStyle(
            fontSize: 12,
            height: 1.45,
            color: AppTokensV2.fgSoft,
          ),
        ),
      ),
      child: SvgPicture.asset(
        AppAssets.icQuestion,
        width: 20,
        colorFilter: const ColorFilter.mode(
          AppTokensV2.fgMuted,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
