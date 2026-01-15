import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_cubit.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_state.dart';
import 'package:pm_app/app/features/widgets/expenable_section.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/features/widgets/info_box_special.dart';
import 'package:pm_app/app/features/widgets/info_row_special.dart';
import 'package:pm_app/app/features/widgets/info_row.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:flutter/rendering.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _cubit = GetIt.I.get<PersonalCubit>();

  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
              titleAppbar: s.personal_info_title,
              haveBackButton: true,
              isTransparent: true,
              backAction: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      body: BlocBuilder<PersonalCubit, PersonalState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.profile;
          if (user == null) {
            return const Center(child: Text("Lỗi tải thông tin"));
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (scroll) {
              if (scroll.direction == ScrollDirection.reverse) {
                if (_showAppBar) setState(() => _showAppBar = false);
              } else if (scroll.direction == ScrollDirection.forward) {
                if (!_showAppBar) setState(() => _showAppBar = true);
              }
              return true;
            },
            child: CustomScrollView(
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
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    _buildAvatar(
                                      user.avatarUrl,
                                      96,
                                    ),
                                    // Container(
                                    //   width: 28,
                                    //   height: 28,
                                    //   decoration: const BoxDecoration(
                                    //     color: Colors.white,
                                    //     shape: BoxShape.circle,
                                    //   ),
                                    //   child: const Icon(
                                    //     Icons.camera_alt,
                                    //     size: 16,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  user.name ?? "-",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Text(
                                    "${user.jobTitle ?? ""} • ${s.employee_card_id}: ${user.employeeCode ?? ""} • ${user.phone ?? ""}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ExpandableSection(
                        title: s.employee_personal,
                        initiallyExpanded: true,
                        style: ExpandableStyle.minimal,
                        children: [
                          InfoBoxSpecial(
                            children: [
                              InfoRow(
                                title: s.profile_info_name,
                                subtitle: user.name ?? "-",
                                showDivider: false,
                              ),
                              InfoRow(
                                title: "Email",
                                subtitle: user.email ?? "-",
                                showDivider: false,
                              ),
                              InfoRow(
                                title: s.profile_info_address,
                                subtitle: user.currentAddress ?? "-",
                                showDivider: false,
                              ),
                            ],
                          ),
                        ],
                      ),

                      ExpandableSection(
                        title: s.profile_job_position,
                        initiallyExpanded: true,
                        style: ExpandableStyle.minimal,
                        children: [
                          InfoBoxSpecial(
                            children: [
                              InfoRowSpecial(
                                title: user.jobTitle ?? "-",
                                subtitlePrefix: s.profile_jobTitle,
                                subtitleValue: user.jobTitle ?? "-",
                                showDivider: false,
                              ),
                              const SizedBox(height: 12),
                              InfoRowSpecial(
                                title: user.department?.name ?? "-",
                                subtitlePrefix: s.profile_manager,
                                subtitleValue: user.manager?.name ?? "-",
                                showDivider: false,
                              ),
                              const SizedBox(height: 12),
                              InfoRowSpecial(
                                title: user.state == "work"
                                    ? s.profile_work
                                    : "-",
                                subtitlePrefix: s.profile_address,
                                subtitleValue: user.workLocation ?? "-",
                                showDivider: false,
                              ),
                            ],
                          ),
                        ],
                      ),

                      ExpandableSection(
                        title: s.profile_other,
                        initiallyExpanded: true,
                        style: ExpandableStyle.minimal,
                        children: [
                          InfoBoxSpecial(
                            children: [
                              InfoRowSpecial(
                                title: user.contractStatus == "signed"
                                    ? s.profile_status1
                                    : s.profile_status2,
                                subtitlePrefix: s.profile_dateJoin,
                                subtitleValue:
                                    user.dateJoinCompany ?? "-",
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: Image.network(
          url ?? '',
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
        ),
      ),
    );
  }
}
