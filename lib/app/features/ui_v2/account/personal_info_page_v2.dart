import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_cubit.dart';
import 'package:pm_app/app/features/ui/account/personal_info/personal_state.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Thông tin cá nhân — phiên bản giao diện tối (v2). Hành vi giữ nguyên
/// bản cũ (`personal_info_page.dart`): tải hồ sơ qua [PersonalCubit.fetchUserInfo],
/// hiển thị cùng các trường (chỉ đọc, không có luồng lưu). Chỉ trình bày đổi.
///
/// Lưu ý dữ liệu: [ProfileEntity.phone] có kiểu `bool?` (Odoo trả `false` khi
/// rỗng) chứ không phải chuỗi số điện thoại, nên màn này KHÔNG hiển thị nó
/// (bản cũ có nội suy `user.phone` vào dòng meta ở header — đây là lỗi hiển
/// thị true/false đã có sẵn ở bản cũ, không mirror lại ở bản v2 theo đúng
/// hướng dẫn "không render true/false cho người dùng").
class PersonalInfoPageV2 extends StatefulWidget {
  const PersonalInfoPageV2({super.key});

  @override
  State<PersonalInfoPageV2> createState() => _PersonalInfoPageV2State();
}

class _PersonalInfoPageV2State extends State<PersonalInfoPageV2> {
  final _cubit = GetIt.I.get<PersonalCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: StaggerRevealV2(index: 0, child: _topBar(s)),
              ),
              Expanded(
                child: BlocBuilder<PersonalCubit, PersonalState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                            color: AppTokensV2.accent, strokeWidth: 2.2),
                      );
                    }

                    final user = state.profile;
                    if (user == null) {
                      return Center(
                        child: Text(s.v2_main_load_info_error,
                            style: AppTokensV2.captionStrong),
                      );
                    }

                    final meta = [
                      if ((user.jobTitle ?? '').isNotEmpty) user.jobTitle!,
                      if ((user.employeeCode ?? '').isNotEmpty)
                        '${s.employee_card_id}: ${user.employeeCode}',
                    ].join('  •  ');

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                      children: [
                        StaggerRevealV2(
                          index: 1,
                          child: GlassCardV2(
                            padding: const EdgeInsets.symmetric(
                                vertical: 22, horizontal: 18),
                            child: Column(children: [
                              _avatar(user.avatarUrl, user.name ?? ''),
                              const SizedBox(height: 14),
                              Text(user.name ?? '-',
                                  style:
                                      AppTokensV2.title.copyWith(fontSize: 19),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              if (meta.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(meta,
                                    style: AppTokensV2.captionStrong,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ]),
                          ),
                        ),
                        const SizedBox(height: 18),
                        StaggerRevealV2(
                          index: 2,
                          child: _sectionCard(s.employee_personal, [
                            _InfoRowData(s.profile_info_name, user.name),
                            _InfoRowData("Email", user.email),
                            _InfoRowData(
                                s.profile_info_address, user.currentAddress),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        StaggerRevealV2(
                          index: 3,
                          child: _sectionCard(s.profile_job_position, [
                            _InfoRowData(s.profile_jobTitle, user.jobTitle),
                            _InfoRowData(
                                s.employee_card_department,
                                user.department?.name),
                            _InfoRowData(s.profile_manager, user.manager?.name),
                            _InfoRowData(
                                s.profile_address, user.workLocation),
                            _InfoRowData(
                                s.v2_main_work_status,
                                user.state == "work" ? s.profile_work : null),
                          ]),
                        ),
                        const SizedBox(height: 14),
                        StaggerRevealV2(
                          index: 4,
                          child: _sectionCard(s.profile_other, [
                            _InfoRowData(
                              s.profile_dateJoin,
                              user.dateJoinCompany,
                            ),
                            _InfoRowData(
                              s.v2_main_contract,
                              user.contractStatus == "signed"
                                  ? s.profile_status1
                                  : s.profile_status2,
                            ),
                          ]),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.personal_info_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _avatar(String? url, String name) {
    final raw = url?.trim();
    final uri = (raw == null || raw.isEmpty) ? null : Uri.tryParse(raw);
    final valid = uri != null && uri.hasScheme && uri.host.isNotEmpty;

    Widget fallback() {
      final parts = name.trim().split(RegExp(r'\s+'));
      String initials = 'U';
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        initials = parts.length == 1
            ? parts.first.characters.first.toUpperCase()
            : (parts.first.characters.first + parts.last.characters.first)
                .toUpperCase();
      }
      return Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppTokensV2.accentGradient, shape: BoxShape.circle),
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTokensV2.border, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokensV2.glow,
              blurRadius: 26,
              offset: const Offset(0, 8))
        ],
      ),
      child: ClipOval(
        child: valid
            ? CachedNetworkImage(
                imageUrl: raw!,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback(),
                errorWidget: (_, __, ___) => fallback(),
              )
            : fallback(),
      ),
    );
  }

  Widget _sectionCard(String title, List<_InfoRowData> rows) {
    final visible = rows.where((r) => (r.value ?? '').trim().isNotEmpty).toList();
    return GlassCardV2(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTokensV2.section),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text('-', style: AppTokensV2.caption)
          else
            for (var i = 0; i < visible.length; i++) ...[
              _infoRow(visible[i]),
              if (i != visible.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _infoRow(_InfoRowData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(data.label, style: AppTokensV2.caption),
        ),
        Expanded(
          child: Text(
            data.value ?? '-',
            style: AppTokensV2.body.copyWith(fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _InfoRowData {
  final String label;
  final String? value;
  const _InfoRowData(this.label, this.value);
}
