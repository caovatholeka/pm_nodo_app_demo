import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../widgets/expenable_section.dart';
import '../../../widgets/primary_button.dart';
import '../../../../data/models/entities/profile_entity.dart';
import 'personal_cubit.dart';
import 'personal_state.dart';
import 'package:pm_app/app/features/widgets/info_box_special.dart';
import 'package:pm_app/app/features/widgets/info_row_special.dart';
import 'package:pm_app/app/features/widgets/info_row.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _cubit = GetIt.I.get<PersonalCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Cá nhân",
        haveBackButton: true,
        backAction: () => Navigator.pop(context),
      ),
      body: BlocBuilder<PersonalCubit, PersonalState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading)
            return const Center(child: CircularProgressIndicator());
          final user = state.profile;
          if (user == null)
            return const Center(child: Text("Lỗi tải thông tin"));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Container(
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
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      image: DecorationImage(
                                        image:
                                            (user.avatarUrl != null &&
                                                    user.avatarUrl!.isNotEmpty)
                                                ? NetworkImage(user.avatarUrl!)
                                                : AssetImage(
                                                      AppAssets.img_df_avatar,
                                                    )
                                                    as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                    ),
                                  ),
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
                                  "${user.jobTitle ?? ""} • ${user.employeeCode ?? ""} • ${user.phone ?? ""}",
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
                      title: "Hồ sơ cá nhân",
                      initiallyExpanded: true,
                      style: ExpandableStyle.secondary,
                      children: [
                        InfoBoxSpecial(
                          children: [
                            InfoRow(
                              title: "Tên nhân viên",
                              subtitle: user.name ?? "-",
                            ),
                            InfoRow(
                              title: "Email",
                              subtitle: user.email ?? "-",
                            ),
                            InfoRow(
                              title: "Địa chỉ",
                              subtitle: user.currentAddress ?? "-",
                              showDivider: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpandableSection(
                      title: "Thông tin vị trí công tác",
                      initiallyExpanded: true,
                      style: ExpandableStyle.secondary,
                      children: [
                        InfoBoxSpecial(
                          children: [
                            InfoRowSpecial(
                              title: user.jobTitle ?? "-",
                              subtitlePrefix: "Chức danh: ",
                              subtitleValue: user.jobTitle ?? "-",
                            ),
                            InfoRowSpecial(
                              title: user.department?.name ?? "-",
                              subtitlePrefix: "Quản lý: ",
                              subtitleValue: user.manager?.name ?? "-",
                            ),
                            InfoRowSpecial(
                              title:
                                  user.state == "work" ? "Đang làm việc" : "-",
                              subtitlePrefix: "Địa chỉ làm việc: ",
                              subtitleValue: user.workLocation ?? "-",
                              showDivider: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpandableSection(
                      title: "Khác",
                      initiallyExpanded: true,
                      style: ExpandableStyle.secondary,
                      children: [
                        InfoBoxSpecial(
                          children: [
                            InfoRowSpecial(
                              title:
                                  user.contractStatus == "signed"
                                      ? "Đã ký hợp đồng"
                                      : "Chưa ký",
                              subtitlePrefix: "Ngày gia nhập: ",
                              subtitleValue: user.dateJoinCompany ?? "-",
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
        },
      ),
    );
  }
}
