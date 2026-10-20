import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/utils.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/widgets/contact_action_text.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Chi tiết nhân viên — giao diện tối (v2).
///
/// Trình bày lại theo phong cách v2 (header + các thẻ [GlassCardV2] theo
/// nhóm), giữ nguyên nghiệp vụ bản cũ (`lib/app/features/ui/staff/staff_detail_page.dart`):
/// tái dùng [StaffCubit], cùng cách tải/đọc state, cùng các trường + nhãn hiển thị.
class StaffDetailPageV2 extends StatefulWidget {
  final int employeeId;

  const StaffDetailPageV2({super.key, required this.employeeId});

  @override
  State<StaffDetailPageV2> createState() => _StaffDetailPageV2State();
}

class _StaffDetailPageV2State extends State<StaffDetailPageV2> {
  final _cubit = GetIt.I.get<StaffCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getDetailEmployee(widget.employeeId);
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
                child: BlocBuilder<StaffCubit, StaffState>(
                  bloc: _cubit,
                  builder: (context, state) => _body(context, s, state),
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
          s.employee_detail_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _body(BuildContext context, S s, StaffState state) {
    if (state.loadStatus == LoadStatus.LOADING) {
      return Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.2, color: AppTokensV2.accent),
      );
    }

    if (state.loadStatus == LoadStatus.FAILURE) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline_rounded,
                size: 44, color: AppTokensV2.danger),
            const SizedBox(height: 10),
            Text(s.employee_nofound,
                style: AppTokensV2.captionStrong,
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final employee = state.employee;
    if (employee == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.person_off_outlined,
                size: 44, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text(s.employee_no_data,
                style: AppTokensV2.captionStrong,
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final isWorking = (employee.active ?? '') == 'work';
    final isSigned = (employee.contractStatus ?? '') == 'signed';
    // `currentAddress` là bool? trong model (Odoo trả về `false` khi trường rỗng,
    // không phải chuỗi địa chỉ thật) nên không có giá trị thật để hiển thị — bỏ dòng này.
    final hasEmail = (employee.workEmail ?? '').trim().isNotEmpty;
    final hasPhone = (employee.phone ?? '').trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
      children: [
        StaggerRevealV2(index: 1, child: _header(s, employee)),
        const SizedBox(height: 18),

        StaggerRevealV2(
          index: 2,
          child: _sectionLabel(s.employee_personal),
        ),
        const SizedBox(height: 8),
        StaggerRevealV2(
          index: 2,
          child: GlassCardV2(
            child: Column(children: [
              _row(s.employee_per1, employee.name ?? '-'),
              _divider(),
              _row(
                s.employee_per2,
                employee.phone ?? '-',
                valueWidget: hasPhone
                    ? ContactActionText(
                        value: employee.phone!,
                        type: ContactType.phone,
                        style: AppTokensV2.body.copyWith(
                            color: AppTokensV2.accent,
                            decoration: TextDecoration.underline),
                      )
                    : null,
              ),
              _divider(),
              _row(
                'Email',
                employee.workEmail ?? '-',
                valueWidget: hasEmail
                    ? ContactActionText(
                        value: employee.workEmail!,
                        type: ContactType.email,
                        style: AppTokensV2.body.copyWith(
                            color: AppTokensV2.accent,
                            decoration: TextDecoration.underline),
                      )
                    : null,
              ),
            ]),
          ),
        ),
        const SizedBox(height: 18),

        StaggerRevealV2(
          index: 3,
          child: _sectionLabel(s.employee_job_detail),
        ),
        const SizedBox(height: 8),
        StaggerRevealV2(
          index: 3,
          child: GlassCardV2(
            child: Column(children: [
              _statusBadge(
                  isWorking, s.profile_work, s.profile_not_work),
              _divider(),
              _row(s.employee_jd1, employee.jobTitle ?? '-'),
              _divider(),
              _row(s.employee_card_department, employee.department ?? '-'),
              _divider(),
              _row(s.employee_jd2, employee.managerby ?? '-'),
              _divider(),
              _row(s.employee_jd3, employee.workLocation ?? '-'),
            ]),
          ),
        ),
        const SizedBox(height: 18),

        StaggerRevealV2(
          index: 4,
          child: _sectionLabel(s.employee_other),
        ),
        const SizedBox(height: 8),
        StaggerRevealV2(
          index: 4,
          child: GlassCardV2(
            child: Column(children: [
              _statusBadge(
                  isSigned, s.profile_status1, s.profile_status2),
              _divider(),
              _row(s.employee_o1, employee.dateJoinCompany ?? '-'),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: AppTokensV2.section);

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppTokensV2.border),
      );

  /// Nhãn trạng thái (đang làm việc / đã ký hợp đồng, v.v.) — thay cho tiêu đề
  /// in đậm ở bản cũ ([InfoRowSpecial.title]), không kèm nhãn phụ vì bản cũ
  /// cũng không có nhãn cho dòng này.
  Widget _statusBadge(bool positive, String positiveText, String negativeText) {
    final color = positive ? AppTokensV2.success : AppTokensV2.fgMuted;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          positive ? positiveText : negativeText,
          style: AppTokensV2.body.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {Widget? valueWidget}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: AppTokensV2.captionStrong),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget ??
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTokensV2.body,
                ),
          ),
        ),
      ],
    );
  }

  Widget _header(S s, EmployeeEntity employee) {
    final job = (employee.jobTitle ?? '').trim();
    final dept = (employee.department ?? '').trim();
    final code = employee.code;

    return GlassCardV2(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      child: Column(
        children: [
          _avatar(employee.avatarUrl, employee.name ?? '-'),
          const SizedBox(height: 14),
          Text(
            employee.name ?? '-',
            style: AppTokensV2.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (job.isNotEmpty || dept.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              [if (job.isNotEmpty) job, if (dept.isNotEmpty) dept]
                  .join(' • '),
              style: AppTokensV2.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (code != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTokensV2.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${s.employee_card_id}: $code',
                style: AppTokensV2.caption.copyWith(
                    color: AppTokensV2.accent, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatar(String? avatar, String name) {
    Widget fallback() {
      final parts = name.trim().split(RegExp(r'\s+'));
      var initials = 'U';
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
        child: Text(
          initials,
          style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
        ),
      );
    }

    final raw = avatar?.trim();
    if (raw == null || raw.isEmpty) {
      return ClipOval(child: fallback());
    }

    if (raw.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          raw,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return fallback();
          },
        ),
      );
    }

    final bytes = Utils().decodeBase64(raw);
    if (bytes == null || bytes.isEmpty) {
      return ClipOval(child: fallback());
    }
    return ClipOval(
      child: Image.memory(
        bytes,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }
}
