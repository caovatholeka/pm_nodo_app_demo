import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';

import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/network/api_client.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

import 'package:pm_app/app/features/widgets/expenable_section.dart';
import 'package:pm_app/app/features/widgets/info_box_special.dart';
import 'package:pm_app/app/features/widgets/info_row.dart';
import 'package:pm_app/app/features/widgets/info_row_special.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import '../../../core/network/api_util.dart';
import 'employee_detail_cubit.dart';


class EmployeeDetailPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailPage({super.key, required this.employeeId});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  late final EmployeeDetailCubit _cubit;

  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    // final apiClient = GetIt.I.get<ApiClient>();
    ApiClient apiClient = ApiUtil.instance.createApiClient();
    _cubit = EmployeeDetailCubit(apiClient: apiClient);
    _cubit.getDetailEmployee(widget.employeeId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  ImageProvider _buildAvatarImage(String? base64String) {
    if (base64String == null || base64String.trim().isEmpty) {
      return AssetImage(AppAssets.img_df_avatar);
    }

    try {
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      final bytes = base64Decode(cleaned);
      if (bytes.isEmpty) {
        return AssetImage(AppAssets.img_df_avatar);
      }
      return MemoryImage(bytes);
    } catch (e) {
      return AssetImage(AppAssets.img_df_avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      bloc: _cubit,
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
                  titleAppbar: "Chi tiết nhân viên",
                  haveBackButton: true,
                  isTransparent: true,
                  backAction: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          body: NotificationListener<UserScrollNotification>(
            onNotification: (scroll) {
              if (scroll.direction == ScrollDirection.reverse) {
                if (_showAppBar) setState(() => _showAppBar = false);
              } else if (scroll.direction == ScrollDirection.forward) {
                if (!_showAppBar) setState(() => _showAppBar = true);
              }
              return true;
            },

            child: Builder(
              builder: (_) {
                if (state.loadStatus == LoadStatus.LOADING) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.loadStatus == LoadStatus.FAILURE) {
                  return const Center(
                    child: Text(
                      "Không thể tải thông tin nhân viên",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                if (employee == null) {
                  return const Center(child: Text("Không có dữ liệu nhân viên"));
                }

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
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        image: DecorationImage(
                                          image: _buildAvatarImage(
                                            employee.avatarUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
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
                                      "${employee.jobTitle ?? ""} • NV${employee.code ?? "--"} • ${employee.phone ?? ""}",
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
                            title: "Thông tin cá nhân",
                            initiallyExpanded: true,
                            style: ExpandableStyle.minimal,
                            children: [
                              InfoBoxSpecial(
                                children: [
                                  InfoRow(
                                    title: "Tên nhân viên",
                                    subtitle: employee.name ?? "-",
                                    showDivider: false,
                                  ),
                                  InfoRow(
                                    title: "Số điện thoại",
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
                                  InfoRow(
                                    title: "Địa chỉ",
                                    subtitle:
                                        "${employee.currentAddress ?? "-"}",
                                    showDivider: false,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          ExpandableSection(
                            title: "Thông tin công việc",
                            style: ExpandableStyle.minimal,
                            initiallyExpanded: true,
                            children: [
                              InfoBoxSpecial(
                                children: [
                                  InfoRowSpecial(
                                    title: employee.jobTitle ?? "-",
                                    subtitlePrefix: "Chức danh: ",
                                    subtitleValue: employee.jobTitle ?? "-",
                                    showDivider: false,
                                  ),
                                  const SizedBox(height: 12),
                                  InfoRowSpecial(
                                    title: employee.department ?? "-",
                                    subtitlePrefix: "Quản lý: ",
                                    subtitleValue: employee.managerby ?? "-",
                                    showDivider: false,
                                  ),
                                  const SizedBox(height: 12),
                                  InfoRowSpecial(
                                    title: (employee.active ?? "") == "work"
                                        ? "Đang làm việc"
                                        : "Đã nghỉ việc",
                                    subtitlePrefix: "Địa chỉ làm việc: ",
                                    subtitleValue:
                                    (employee.xlocationType ?? "") == "inhouse" ?
                                      "Văn phòng công ty" : "Onsite",
                                    showDivider: false,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          ExpandableSection(
                            title: "Khác",
                            initiallyExpanded: true,
                            style: ExpandableStyle.minimal,
                            children: [
                              InfoBoxSpecial(
                                children: [
                                  InfoRowSpecial(
                                    title:
                                      (employee.contractStatus ?? "") == "signed" ? "Đã ký hợp đồng" : "Chưa ký",
                                    subtitlePrefix: "Ngày gia nhập: ",
                                    subtitleValue:
                                        employee.dateJoinCompany ?? "-",
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
          ),
        );
      },
    );
  }
}
