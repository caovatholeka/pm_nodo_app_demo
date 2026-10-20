import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/data/models/entities/birthdays_entity.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';

/// Bản v2 (dark) của `BirthdayListTile`
/// (lib/app/features/ui/dashboard/widgets/birthday_card.dart).
/// Cùng contract dữ liệu, chỉ đổi màu/kiểu chữ sang [AppTokensV2].
class BirthdayListTileV2 extends StatelessWidget {
  final BirthdaysEntity employee;

  const BirthdayListTileV2({super.key, required this.employee});

  String get _avatarUrl {
    final rawAvatar = employee.avatar?.trim() ?? '';
    final isNetworkImage =
        rawAvatar.startsWith('http://') || rawAvatar.startsWith('https://');
    return isNetworkImage ? rawAvatar : '';
  }

  String get _displayBirthDate {
    final rawDate = employee.birthDate;
    if (rawDate == null || rawDate.trim().isEmpty) {
      return '--/--/----';
    }

    for (final pattern in ['yyyy-MM-dd', 'dd-MM-yyyy', 'yyyy-MM-dd HH:mm:ss']) {
      try {
        return DateFormat('dd/MM/yyyy').format(
          DateFormat(pattern).parse(rawDate),
        );
      } catch (_) {
        continue;
      }
    }

    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppCircleAvatar(
          url: _avatarUrl,
          size: 54,
          defaultAvatar: AppAssets.img_df_avatar,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name ?? '--',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokensV2.body.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                _displayBirthDate,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokensV2.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
