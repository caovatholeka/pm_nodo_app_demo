import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';

enum ExpandableStyle { primary, secondary, minimal }

class ExpandableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ExpandableStyle style;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.style = ExpandableStyle.primary,
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);

    if (isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onExpansionChanged(bool expanded) {
    setState(() {
      isExpanded = expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  Color getContentBackground() {
    switch (widget.style) {
      case ExpandableStyle.primary:
        return const Color(0xFFF7F7F9);
      case ExpandableStyle.secondary:
        return const Color(0xFFF5F6F7);
      case ExpandableStyle.minimal:
        return const Color(0xFFFAFAFA);
    }
  }

  TextStyle getTitleStyle() {
    switch (widget.style) {
      case ExpandableStyle.primary:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
      case ExpandableStyle.secondary:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case ExpandableStyle.minimal:
        return const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
    }
  }

  Color getArrowColor() {
    switch (widget.style) {
      case ExpandableStyle.primary:
        return AppColors.themePrimaryDefault; 
      case ExpandableStyle.secondary:
        return Colors.black54;
      case ExpandableStyle.minimal:
        return Colors.black38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(widget.title, style: getTitleStyle()),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          trailing: RotationTransition(
            turns: _arrowAnimation,
            child: Icon(Icons.keyboard_arrow_up,
                size: 26, color: getArrowColor()),
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: _onExpansionChanged,
          childrenPadding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: getContentBackground(),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            )
          ],
        ),
      ),
    );
  }
}
