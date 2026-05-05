import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/entities/birthdays_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/dashboard/cubit/dashboard_cubit.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/generated/l10n.dart';

class BirthdayCard extends StatelessWidget {
  final VoidCallback? onTap;

  const BirthdayCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
                const BirthdayHeader(),
                const SizedBox(height: 16),
                BirthdayHorizontalContent(
                  state: state,
                  onTap: onTap,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BirthdayDetailSection extends StatefulWidget {
  const BirthdayDetailSection({super.key});

  @override
  State<BirthdayDetailSection> createState() => _BirthdayDetailSectionState();
}

class _BirthdayDetailSectionState extends State<BirthdayDetailSection> {
  int _selectedMonth = DateTime.now().month;

  String _monthLabel(BuildContext context) =>
      '${S.of(context).month} ${_selectedMonth.toString().padLeft(2, '0')}/${DateTime.now().year}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().getBirthdaysThisMonth(_selectedMonth);
    });
  }

  void _pickMonth() {
    final s = S.of(context);
    int tempMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        s.cancel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                        });
                        context.read<DashboardCubit>().getBirthdaysThisMonth(
                              tempMonth,
                            );
                        Navigator.pop(context);
                      },
                      child: Text(
                        s.day_off_donebtn,
                        style: const TextStyle(
                          color: Color(0xFF2E87FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: tempMonth - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    tempMonth = index + 1;
                  },
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(
                        '${s.month} ${(i + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.birthdayStatus != current.birthdayStatus ||
            previous.birthdays != current.birthdays,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BirthdayHeader(),
              const SizedBox(height: 16),
              BirthdayMonthPicker(
                label: _monthLabel(context),
                onTap: _pickMonth,
              ),
              const SizedBox(height: 14),
              BirthdayVerticalContent(state: state),
            ],
          );
        },
      ),
    );
  }
}

class BirthdayHeader extends StatelessWidget {
  const BirthdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
        Text(
          s.appraisal_birthday_month_title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5C678D),
          ),
        ),
      ],
    );
  }
}

class BirthdayMonthPicker extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const BirthdayMonthPicker({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SvgPicture.asset(AppAssets.icCalendar, width: 14, height: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class BirthdayHorizontalContent extends StatelessWidget {
  final DashboardState state;
  final VoidCallback? onTap;

  const BirthdayHorizontalContent({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (state.birthdayStatus == LoadStatus.LOADING && state.birthdays.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (state.birthdayStatus == LoadStatus.FAILURE && state.birthdays.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            s.appraisal_load_failed,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    if (state.birthdays.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            s.appraisal_no_birthdays_this_month,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
          return BirthdayAvatarItem(
            employee: state.birthdays[index],
            onTap: onTap,
          );
        },
      ),
    );
  }
}

class BirthdayVerticalContent extends StatelessWidget {
  final DashboardState state;

  const BirthdayVerticalContent({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (state.birthdayStatus == LoadStatus.LOADING && state.birthdays.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (state.birthdayStatus == LoadStatus.FAILURE && state.birthdays.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            s.appraisal_load_failed,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    if (state.birthdays.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            s.appraisal_no_birthdays_this_month,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.birthdays.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return BirthdayListTile(employee: state.birthdays[index]);
      },
    );
  }
}

class BirthdayAvatarItem extends StatelessWidget {
  final BirthdaysEntity employee;
  final VoidCallback? onTap;

  const BirthdayAvatarItem({
    super.key,
    required this.employee,
    this.onTap,
  });

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
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
                      color: _isTodayBirthday
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFA78BFA),
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
                fontWeight:
                    _isTodayBirthday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (_isTodayBirthday)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  S.of(context).attendance_card1,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BirthdayListTile extends StatelessWidget {
  final BirthdaysEntity employee;

  const BirthdayListTile({
    super.key,
    required this.employee,
  });

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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _displayBirthDate,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B8B8B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
