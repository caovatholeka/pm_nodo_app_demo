import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../widgets/expenable_section.dart';
import '../../../widgets/primary_button.dart';
import 'personal_cubit.dart';
import 'personal_state.dart';
import '../../../../data/models/entities/profile_entity.dart';

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
            return const Center(child: Text("Không thể tải thông tin người dùng"));
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
                user.name ?? "Chưa có tên",
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
                  _InfoItem(title: "Ngày sinh", value: user.birthdayDate ?? "Ko Có :("),
                  _InfoItem(title: "Mã nhân viên", value: user.code ?? "Ko Có :("),
                  _InfoItem(title: "Số điện thoại", value: user.phone?.toString() ?? "Ko Có :("),
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
                image: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ExpandableSection(
            title: "Hồ sơ cá nhân",
            initiallyExpanded: true,
            children: [
              _infoBox([
                _InfoRow(title: "Tên nhân viên", value: user.name ?? "Ko phải của Nodo :)"),
                const SizedBox(height: 5),
                Divider(height: 0.1, color: const Color.fromARGB(33, 221, 221, 221),),
                const SizedBox(height: 5),
                _InfoRow(title: "Email", value: user.email ?? "Làm gì có mail :)"),
                const SizedBox(height: 5),
                Divider(height: 0.1, color: const Color.fromARGB(33, 221, 221, 221),),
                const SizedBox(height: 5),
                _InfoRow(title: "Địa chỉ", value: "Không có đừng tìm :((((("),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          ExpandableSection(
            title: "Thông tin vị trí công tác",
            initiallyExpanded: true,
            children: [
              _infoBox([
                _InfoRow(title: "Chức danh", value: "Ko Có:("),
                const SizedBox(height: 5),
                Divider(height: 0.1, color: const Color.fromARGB(33, 221, 221, 221),),
                const SizedBox(height: 5),
                _InfoRow(title: "Phòng ban", value: user.department?.name ?? "Ko có :("),
                const SizedBox(height: 5),
                Divider(height: 0.1, color: const Color.fromARGB(33, 221, 221, 221),),
                const SizedBox(height: 5),
                _InfoRow(title: "Trạng thái", value: "Ko Có:("),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          ExpandableSection(
            title: "Khác",
            initiallyExpanded: true,
            children: [
              _infoBox([
                _InfoRow(title: "Đã ký hợp đồng", value: "Làm gì có :("),
              ]),
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

  Widget _infoBox(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top:12, left:16, right:12, bottom:16),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(243, 240, 240, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
            style: const TextStyle(
              color: AppColors.avatarText,
              fontSize: 12,
            ),
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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
