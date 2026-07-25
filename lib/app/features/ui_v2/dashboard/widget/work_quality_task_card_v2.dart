import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bản v2 (dark) của `WorkQualityTaskList` / `WorkQualityTaskCard`
/// (lib/app/features/ui/dashboard/widgets/work_quality_task_card.dart).
/// Cùng contract dữ liệu [WorkQualityTaskItemDataV2].
class WorkQualityTaskListV2 extends StatelessWidget {
  final List<WorkQualityTaskItemDataV2> items;

  const WorkQualityTaskListV2({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          WorkQualityTaskCardV2(item: items[i]),
          if (i != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class WorkQualityTaskCardV2 extends StatelessWidget {
  final WorkQualityTaskItemDataV2 item;

  const WorkQualityTaskCardV2({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProjectLogoV2(path: item.projectLogo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokensV2.section.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokensV2.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“${item.description}”',
            style: AppTokensV2.body.copyWith(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: AppTokensV2.fgSoft,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoTextV2(
                  title: s.appraisal_assignee,
                  value: item.owner,
                  valueColor: AppTokensV2.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoTextV2(
                  title: s.appraisal_execution_time,
                  value: item.duration,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: item.tags.map((tag) => _TagChipV2(text: tag)).toList(),
          ),
        ],
      ),
    );
  }
}

class WorkQualityTaskItemDataV2 {
  final String title;
  final String subtitle;
  final String description;
  final String owner;
  final String duration;
  final List<String> tags;
  final String projectLogo;

  const WorkQualityTaskItemDataV2({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.owner,
    required this.duration,
    required this.tags,
    this.projectLogo = '',
  });
}

class _InfoTextV2 extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoTextV2({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTokensV2.caption),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTokensV2.body.copyWith(
            fontSize: 13,
            color: valueColor ?? AppTokensV2.fg,
          ),
        ),
      ],
    );
  }
}

class _TagChipV2 extends StatelessWidget {
  final String text;

  const _TagChipV2({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: AppTokensV2.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTokensV2.accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: AppTokensV2.caption.copyWith(
          color: AppTokensV2.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProjectLogoV2 extends StatelessWidget {
  final String path;

  const _ProjectLogoV2({required this.path});

  @override
  Widget build(BuildContext context) {
    final logo = path.trim();

    if (logo.isEmpty) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTokensV2.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokensV2.border),
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
          color: AppTokensV2.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokensV2.border),
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
