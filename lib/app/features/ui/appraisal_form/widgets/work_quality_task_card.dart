import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/generated/l10n.dart';

class WorkQualityTaskList extends StatelessWidget {
  final List<WorkQualityTaskItemData> items;

  const WorkQualityTaskList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          WorkQualityTaskCard(item: items[i]),
          if (i != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class WorkQualityTaskCard extends StatelessWidget {
  final WorkQualityTaskItemData item;

  const WorkQualityTaskCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProjectLogo(path: item.projectLogo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3D4B7A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“${item.description}”',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoText(
                  title: s.appraisal_assignee,
                  value: item.owner,
                  valueColor: const Color(0xFF1677FF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoText(
                  title: s.appraisal_execution_time,
                  value: item.duration,
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: item.tags.map((tag) => _TagChip(text: tag)).toList(),
          ),
        ],
      ),
    );
  }
}

class WorkQualityTaskItemData {
  final String title;
  final String subtitle;
  final String description;
  final String owner;
  final String duration;
  final List<String> tags;
  final String projectLogo;

  const WorkQualityTaskItemData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.owner,
    required this.duration,
    required this.tags,
    this.projectLogo = '',
  });
}

class _InfoText extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoText({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimaryDefault,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFD8EEF9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1677FF),
        ),
      ),
    );
  }
}

class _ProjectLogo extends StatelessWidget {
  final String path;

  const _ProjectLogo({required this.path});

  @override
  Widget build(BuildContext context) {
    final logo = path.trim();

    if (logo.isEmpty) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EAF3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: SvgPicture.asset(AppAssets.appLogo, fit: BoxFit.contain),
        ),
      );
    }

    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return AppCircleAvatar(
        url: logo,
        size: 42,
        defaultAvatar: AppAssets.appLogo2,
      );
    }

    if (logo.toLowerCase().endsWith('.svg')) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5EAF3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: SvgPicture.asset(logo, fit: BoxFit.contain),
        ),
      );
    }

    return AppCircleAvatar(
      url: logo,
      size: 42,
      defaultAvatar: AppAssets.appLogo2,
    );
  }
}
