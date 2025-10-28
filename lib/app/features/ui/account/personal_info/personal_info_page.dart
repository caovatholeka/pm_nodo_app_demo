import 'package:flutter/material.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import '../../../../core/commons/app_assets.dart';
import '../../../../core/commons/app_colors.dart';
import '../../../widgets/expenable_section.dart';
import '../../../widgets/primary_button.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Thông tin cá nhân",
        haveBackButton: true,
        backAction: () => Navigator.pop(context),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.imgBg2),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              _accountInfo,
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ExpandableSection(
                      title: "Hồ sơ cá nhân",
                      initiallyExpanded: true,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(243, 240, 240, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                  title: "Tên nhân viên",
                                  value: "NGUYỄN MINH DŨNG"),
                              SizedBox(height: 12),
                              Divider(height: 0.5, color: Color.fromRGBO(206, 214, 222, 1)),
                              SizedBox(height: 12),
                              _InfoRow(
                                  title: "Email",
                                  value: "dungmn@monoda.com"),
                              SizedBox(height: 12),
                              Divider(height: 0.5, color: Color.fromRGBO(206, 214, 222, 1)),
                              SizedBox(height: 12),
                              _InfoRow(
                                title: "Địa chỉ",
                                value:
                                    "Liền kề 22 TT03, Khu đô thị Tây Nam Linh Đàm, Hoàng Mai, Hà Nội",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ExpandableSection(
                      title: "Thông tin vị trí công tác",
                      initiallyExpanded: true,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 240, 240, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(title: "Chức danh", value: "UI/UX Designer"),
                              SizedBox(height: 12),
                              Divider(height: 0.5, color: Color.fromRGBO(206, 214, 222, 1)),
                              SizedBox(height: 12),
                              _InfoRow(
                                  title: "Phòng sản xuất",
                                  value: "Quản lý sản xuất - Xuân Thưởng"),
                              SizedBox(height: 12),
                              Divider(height: 0.5, color: Color.fromRGBO(206, 214, 222, 1)),
                              SizedBox(height: 12),
                              _InfoRow(title: "Đang làm việc", value: "ALOHUB Hà Nội"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ExpandableSection(
                      title: "Khác",
                      initiallyExpanded: true,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 240, 240, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                  title: "Đã ký hợp đồng",
                                  value: "Đang hiệu lực"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: PrimaryButton(
                        mainText: "Xác nhận",
                        callback: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  get _accountInfo {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.profileContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "NGUYỄN MINH DŨNG",
                style: TextStyle(
                  color: AppColors.colorPrimary50,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _InfoItem(title: "Ngày sinh", value: "03/01/2002"),
                  _InfoItem(title: "Mã nhân viên", value: "NV33656"),
                  _InfoItem(title: "Số điện thoại", value: "19001000"),
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
                image: AssetImage(AppAssets.img_df_avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
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
