import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/birthdays_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/appraisal_form/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';

class BirthdayCard extends StatelessWidget {
  const BirthdayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.birthdayStatus != current.birthdayStatus ||
            previous.birthdays != current.birthdays,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 16),
              _BirthdayContent(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.icCake,
              width: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Sinh nhật trong tháng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BirthdayContent extends StatelessWidget {
  final DashboardState state;

  const _BirthdayContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.birthdayStatus == LoadStatus.LOADING &&
        state.birthdays.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.birthdayStatus == LoadStatus.FAILURE &&
        state.birthdays.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Không tải được danh sách.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    if (state.birthdays.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Không có sinh nhật trong tháng này .',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.birthdays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _BirthdayItem(employee: state.birthdays[index]);
        },
      ),
    );
  }
}

class _BirthdayItem extends StatelessWidget {
  final BirthdaysEntity employee;

  const _BirthdayItem({required this.employee});

  String get _avatarUrl {
    final rawAvatar = employee.avatar?.trim() ?? '';
    final isNetworkImage =
        rawAvatar.startsWith('http://') || rawAvatar.startsWith('https://');

    return isNetworkImage ? rawAvatar : '';
  }

  String get _displayDate {
    final rawDate = employee.birthDate;
    if (rawDate == null || rawDate.trim().isEmpty) {
      return '--/--';
    }

    for (final pattern in ['yyyy-MM-dd', 'dd-MM-yyyy', 'yyyy-MM-dd HH:mm:ss']) {
      try {
        return DateFormat('dd/MM').format(DateFormat(pattern).parse(rawDate));
      } catch (_) {
        continue;
      }
    }

    try {
      return DateFormat('dd/MM').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  DateTime? get _birthDate {
    final rawDate = employee.birthDate;
    if (rawDate == null || rawDate.trim().isEmpty) {
      return null;
    }

    for (final pattern in ['yyyy-MM-dd', 'dd-MM-yyyy', 'yyyy-MM-dd HH:mm:ss']) {
      try {
        return DateFormat(pattern).parse(rawDate);
      } catch (_) {
        continue;
      }
    }

    return DateTime.tryParse(rawDate);
  }

  bool get _isTodayBirthday {
    final birthDate = _birthDate;
    if (birthDate == null) {
      return false;
    }

    final today = DateTime.now();
    return birthDate.day == today.day && birthDate.month == today.month;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _isTodayBirthday
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFD8B4FE),
                      _isTodayBirthday
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFA78BFA),
                    ],
                  ),
                  boxShadow: _isTodayBirthday
                      ? const [
                          BoxShadow(
                            color: Color(0x33EF4444),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: AppCircleAvatar(
                  url: _avatarUrl,
                  size: 48,
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.cake_rounded,
                    size: 12,
                    color: _isTodayBirthday ? Color(0xFFEF4444) : Color(0xFFA78BFA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            employee.name ?? '--',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            _displayDate,
            style: TextStyle(
              fontSize: 11,
              color: _isTodayBirthday ? const Color(0xFFEF4444) : Colors.grey,
              fontWeight: _isTodayBirthday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (_isTodayBirthday)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Hôm nay',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
