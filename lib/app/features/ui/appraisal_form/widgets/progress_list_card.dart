import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProgressListCard extends StatelessWidget {
  const ProgressListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ProgressItem('PM Nodo', 100),
      _ProgressItem('PM Nodo', 80),
      _ProgressItem('PM Nodo', 80),
      _ProgressItem('PM Nodo', 0),
    ];

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(title: 'Tiến độ dự án', trailing: '1/4 completed'),
          const SizedBox(height: 16),
          ...items.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < items.length - 1 ? 16 : 0,
              ),
              child: _ProgressRow(
                name: entry.value.label,
                percent: entry.value.percent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressItem {
  final String label;
  final int percent;
  _ProgressItem(this.label, this.percent);
}

class _ProgressRow extends StatelessWidget {
  final String name;
  final int percent;

  const _ProgressRow({required this.name, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    percent > 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final filledWidth = barWidth * (percent / 100.0);

            final markerLeft = math.max(
              0.0,
              math.min(filledWidth - 11.0, barWidth - 22.0),
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                if (percent > 0)
                  Container(
                    width: filledWidth,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                if (percent > 0 && percent < 100)
                  Positioned(
                    left: markerLeft,
                    top: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

Widget _headerRow({required String title, required String trailing}) {
  return Row(
    children: [
      Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.trending_up,
          color: Color(0xFF10B981),
          size: 20,
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      Text(
        trailing,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
