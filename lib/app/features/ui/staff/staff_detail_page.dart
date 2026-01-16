import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../core/commons/app_assets.dart';
import '../../../data/models/enums/load_status.dart';
import '../../widgets/expenable_section.dart';
import '../../widgets/info_box_special.dart';
import '../../widgets/info_row.dart';
import '../../widgets/info_row_special.dart';
import '../../widgets/my_app_bar.dart';

class StaffDetailPage extends StatefulWidget {
  final int employeeId;

  const StaffDetailPage({super.key, required this.employeeId});

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  final _cubit = GetIt.I.get<StaffCubit>();

  @override
  void initState() {
    _cubit.getDetailEmployee(widget.employeeId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _showAppBar = true;

  // ImageProvider _buildAvatarImage(String? base64String) {
  //   if (base64String == null || base64String.trim().isEmpty) {
  //     return AssetImage(AppAssets.img_df_avatar);
  //   }

  //   try {
  //     final cleaned =
  //         base64String.contains(',')
  //             ? base64String.split(',').last
  //             : base64String;
  //     final bytes = base64Decode(cleaned);
  //     if (bytes.isEmpty) return AssetImage(AppAssets.img_df_avatar);
  //     return MemoryImage(bytes);
  //   } catch (_) {
  //     return AssetImage(AppAssets.img_df_avatar);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffCubit, StaffState>(
      bloc: _cubit,
      listener: (context, state) {},
      builder: (context, state) {
        final employee = state.employee;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xFFF4F6F8),

          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedOpacity(
              opacity: _showAppBar ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showAppBar,
                child: MyAppBar(
                  titleAppbar: S.of(context).employee_detail_title,
                  haveBackButton: true,
                  isTransparent: true,
                  backAction: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          body: NotificationListener<UserScrollNotification>(
            onNotification: (scroll) {
              if (scroll.direction == ScrollDirection.reverse && _showAppBar) {
                setState(() => _showAppBar = false);
              } else if (scroll.direction == ScrollDirection.forward &&
                  !_showAppBar) {
                setState(() => _showAppBar = true);
              }
              return true;
            },

            child: Builder(
              builder: (_) {
                if (state.loadStatus == LoadStatus.LOADING) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0062FF)));
                }

                if (state.loadStatus == LoadStatus.FAILURE) {
                  return  Center(
                    child: Text(
                      S.of(context).employee_nofound,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                if (employee == null) {
                  return Center(
                    child: Text(S.of(context).employee_no_data),
                  );
                }

                return _buildBody(employee);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(employee) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AppAssets.imgProfileBG,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 110,
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: _buildSafeAvatar(employee.avatarUrl),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          employee.name ?? "-",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${employee.jobTitle ?? ""} • ${S.of(context).employee_card_id}: ${employee.code ?? "--"} • ${employee.phone ?? ""}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(5, 4, 5, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ExpandableSection(
                title: S.of(context).employee_personal,
                initiallyExpanded: true,
                style: ExpandableStyle.minimal,
                children: [
                  InfoBoxSpecial(
                    children: [
                      InfoRow(
                        title: S.of(context).employee_per1,
                        subtitle: employee.name ?? "-",
                        showDivider: false,
                      ),
                      InfoRow(
                        title: S.of(context).employee_per2,
                        subtitle: employee.phone ?? "-",
                        showDivider: false,
                        isClickable: true,
                        type: "phone",
                      ),
                      InfoRow(
                        title: "Email",
                        subtitle: employee.workEmail ?? "-",
                        showDivider: false,
                        isClickable: true,
                        type: "email",
                      ),
                      // InfoRow(
                      //   title: "DOB",
                      //   subtitle: employee.birthday ?? "-",
                      //   showDivider: false,
                      //   ),
                      InfoRow(
                        title: S.of(context).employee_per3,
                        subtitle: employee.currentAddress ?? "-",
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),

              ExpandableSection(
                title: S.of(context).employee_job_detail,
                initiallyExpanded: true,
                style: ExpandableStyle.minimal,
                children: [
                  InfoBoxSpecial(
                    children: [
                      InfoRowSpecial(
                        title: employee.jobTitle ?? "-",
                        subtitlePrefix: S.of(context).employee_jd1,
                        subtitleValue: employee.jobTitle ?? "-",
                        showDivider: false,
                      ),
                      const SizedBox(height: 12),
                      InfoRowSpecial(
                        title: employee.department ?? "-",
                        subtitlePrefix: S.of(context).employee_jd2,
                        subtitleValue: employee.managerby ?? "-",
                        showDivider: false,
                      ),
                      const SizedBox(height: 12),
                      InfoRowSpecial(
                        title:
                            (employee.active ?? "") == "work"
                                ? S.of(context).profile_work
                                : S.of(context).profile_not_work,
                        subtitlePrefix: S.of(context).employee_jd3,
                        subtitleValue: employee.workLocation ?? "-",
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),

              ExpandableSection(
                title: S.of(context).employee_other,
                initiallyExpanded: true,
                style: ExpandableStyle.minimal,
                children: [
                  InfoBoxSpecial(
                    children: [
                      InfoRowSpecial(
                        title:
                            (employee.contractStatus ?? "") == "signed"
                                ? S.of(context).profile_status1
                                : S.of(context).profile_status2,
                        subtitlePrefix: S.of(context).employee_o1,
                        subtitleValue: employee.dateJoinCompany ?? "-",
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

Widget _buildSafeAvatar(String? avatar) {
  if (avatar == null || avatar.trim().isEmpty) {
    return Image.asset(
      AppAssets.img_df_avatar,
      fit: BoxFit.cover,
    );
  }

  if (avatar.startsWith('http')) {
    return Image.network(
      avatar,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          AppAssets.img_df_avatar,
          fit: BoxFit.cover,
        );
      },
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  try {
    final cleaned =
        avatar.contains(',') ? avatar.split(',').last : avatar;
    final bytes = base64Decode(cleaned);

    if (bytes.isEmpty) {
      return Image.asset(AppAssets.img_df_avatar, fit: BoxFit.cover);
    }

    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          AppAssets.img_df_avatar,
          fit: BoxFit.cover,
        );
      },
    );
  } catch (e) {
    return Image.asset(
      AppAssets.img_df_avatar,
      fit: BoxFit.cover,
    );
  }
}


