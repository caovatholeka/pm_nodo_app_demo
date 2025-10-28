import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

class ExpandableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late bool isExpanded;
  late AnimationController _controller;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);

    if (isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onExpansionChanged(bool expanded) {
    setState(() {
      isExpanded = expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
      boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12, 
            spreadRadius: 2, 
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding:
              const EdgeInsets.only(left: 0, right: 0, bottom: 0), 
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          trailing: RotationTransition(
            turns: _arrowAnimation,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black54,
              size: 26,
            ),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: _onExpansionChanged,
          children: widget.children,
        ),
      ),
    );
  }
}
