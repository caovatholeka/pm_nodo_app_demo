import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:super_tooltip/super_tooltip.dart';

class AppraisalHelpTooltip extends StatefulWidget {
  final String message;
  final bool autoShow;

  const AppraisalHelpTooltip({
    super.key,
    required this.message,
    this.autoShow = false,
  });

  @override
  State<AppraisalHelpTooltip> createState() => _AppraisalHelpTooltipState();
}

class _AppraisalHelpTooltipState extends State<AppraisalHelpTooltip> {
  final SuperTooltipController _controller = SuperTooltipController();
  Timer? _hideTimer;
  bool _didAutoShow = false;

  @override
  void initState() {
    super.initState();
    _scheduleAutoShowIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AppraisalHelpTooltip oldWidget) {
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
        backgroundColor: Colors.white,
        borderColor: Color(0xFFE5E7EB),
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
            color: Color(0xFF374151),
          ),
        ),
      ),
      child: SvgPicture.asset(AppAssets.icQuestion, width: 20),
    );
  }
}
