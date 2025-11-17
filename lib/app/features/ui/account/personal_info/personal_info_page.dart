import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/widgets/info_box_special.dart';
import 'package:pm_app/app/features/widgets/info_row_special.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../widgets/expenable_section.dart';
import '../../../widgets/primary_button.dart';
import 'personal_cubit.dart';
import 'personal_state.dart';
import '../../../../data/models/entities/profile_entity.dart';
import 'package:pm_app/app/features/widgets/info_row.dart';

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
        titleAppbar: "Thông tin cá nhân",
        haveBackButton: true,
        backAction: () => Navigator.pop(context),
      ),
      body: BlocBuilder<PersonalCubit, PersonalState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.profile;
          if (user == null) {
            return const Center(
              child: Text("Không thể tải thông tin người dùng"),
            );
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.imgBg2),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  _accountInfo(user),
                  const SizedBox(height: 10),
                  _bodyInfo(user),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _accountInfo(ProfileEntity user) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48, left: 3, right: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.profileContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                user.name ?? "",
                style: const TextStyle(
                  color: AppColors.colorPrimary50,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(title: "Ngày sinh", value: user.birthday ?? ""),
                  _InfoItem(
                    title: "Mã nhân viên",
                    value: user.employeeCode ?? "",
                  ),
                  _InfoItem(
                    title: "Số điện thoại",
                    value: user.phone?.toString() ?? "",
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.avatarFrame, width: 3),
              image: DecorationImage(
                image:
                    (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : AssetImage(AppAssets.img_df_avatar) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bodyInfo(ProfileEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 18, right: 16, left: 10, bottom: 16),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
                    subtitleIsLink: false,
                  ),
                  InfoRow(
                    title: "Email",
                    subtitle: user.email ?? "-",
                    subtitleIsLink: false,
                  ),
                  InfoRow(
                    title: "Địa chỉ",
                    subtitle: user.currentAddress ?? "-",
                    subtitleIsLink: false,
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExpandableSection(
            title: "Thông tin vị trí công tác",
            style: ExpandableStyle.secondary,
            initiallyExpanded: true,
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
                    title: user.state == "work" ? "Đang làm việc" : "-",
                    subtitlePrefix: "Địa chỉ làm việc: ",
                    subtitleValue: user.workLocation ?? "-",
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExpandableSection(
            title: "Khác",
            initiallyExpanded: true,
            style: ExpandableStyle.secondary,
            children: [
              InfoBoxSpecial(
                children: [
                  InfoRowSpecial(
                    title: (user.contractStatus ?? "") == "signed" ? "Đã ký": "Chưa ký", 
                    subtitlePrefix: "Ngày gia nhập: ",
                    showDivider: false,
                     subtitleValue: "")
                ])
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: PrimaryButton(
              mainText: "Xác nhận",
              callback: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  const _InfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.avatarText, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.colorPrimary50,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
