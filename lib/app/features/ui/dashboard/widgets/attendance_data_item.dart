import 'package:flutter/material.dart';

class AttendanceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final double borderRadius;
  final double stripeWidth;
  final double stripeInset;
  final bool curvedStripe;
  final EdgeInsetsGeometry padding;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final double subtitleOpacity;
  final double? titleHeight;
  final double? subtitleHeight;

  const AttendanceItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    this.borderRadius = 12,
    this.stripeWidth = 4,
    this.stripeInset = 0,
    this.curvedStripe = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.titleFontWeight = FontWeight.w600,
    this.subtitleFontWeight = FontWeight.w400,
    this.subtitleOpacity = 0.8,
    this.titleHeight,
    this.subtitleHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (curvedStripe) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: stripeInset,
                bottom: stripeInset,
                child: Container(
                  width: stripeWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius * 0.66),
                      bottomRight: Radius.circular(borderRadius * 0.66),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: _AttendanceText(
                  title: title,
                  subtitle: subtitle,
                  color: color,
                  titleFontWeight: titleFontWeight,
                  subtitleFontWeight: subtitleFontWeight,
                  subtitleOpacity: subtitleOpacity,
                  titleHeight: titleHeight,
                  subtitleHeight: subtitleHeight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border(left: BorderSide(color: color, width: stripeWidth)),
      ),
      child: _AttendanceText(
        title: title,
        subtitle: subtitle,
        color: color,
        titleFontWeight: titleFontWeight,
        subtitleFontWeight: subtitleFontWeight,
        subtitleOpacity: subtitleOpacity,
        titleHeight: titleHeight,
        subtitleHeight: subtitleHeight,
      ),
    );
  }
}

class _AttendanceText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final double subtitleOpacity;
  final double? titleHeight;
  final double? subtitleHeight;

  const _AttendanceText({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.titleFontWeight,
    required this.subtitleFontWeight,
    required this.subtitleOpacity,
    this.titleHeight,
    this.subtitleHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: titleFontWeight,
            height: titleHeight,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: subtitleFontWeight,
            height: subtitleHeight,
            color: color.withValues(alpha: subtitleOpacity),
          ),
        ),
      ],
    );
  }
}
