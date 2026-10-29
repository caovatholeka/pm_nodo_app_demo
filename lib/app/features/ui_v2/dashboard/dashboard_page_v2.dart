import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/dashboard_v2_models.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/dashboard_repository.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/cubit/dashboard_v2_cubit.dart';
import 'package:pm_app/app/features/ui_v2/dashboard/widget/month_picker_sheet_v2.dart';
import 'package:pm_app/app/features/ui_v2/justification/justification_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/on_leave/on_leave_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/overtime/overtime_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/work_trip/work_trip_page_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Dashboard — đồng bộ với Dashboard web (PM): cùng các thẻ, cùng nhãn, và số liệu
/// lấy từ chính các hàm của web (qua API /dashboard/*) nên giống hệt web:
/// - Đơn từ cá nhân trong tháng (Nghỉ phép / Xin OT / Muộn/Sớm / Công tác / WFH)
/// - Đơn cần duyệt cho nhân sự trong tháng (chỉ hiện với người có cấp dưới)
/// - Nề nếp chấm công (Muộn/Sớm, Quên chấm công, Thiếu vào/ra)
/// - Tổng quan nhân sự
/// - Sinh nhật trong tháng
/// - Cảnh báo chuyên cần trong tháng
///
/// Đã bỏ các thẻ web không có dữ liệu (trước đây là dữ liệu giả cố định): Chất lượng công
/// việc, Dự án, chi tiết Nề nếp theo tuần. Hồ sơ cá nhân và Chấm công hôm nay của web đã có
/// ở màn Cá nhân và Trang chủ.
class DashboardPageV2 extends StatefulWidget {
  const DashboardPageV2({super.key});

  @override
  State<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends State<DashboardPageV2> {
  late final DashboardV2Cubit _cubit =
      DashboardV2Cubit(GetIt.I<DashboardRepository>());

  /// Số dòng hiện trên thẻ Sinh nhật / Cảnh báo; còn lại xem ở "Xem tất cả".
  static const int _previewCount = 5;

  @override
  void initState() {
    super.initState();
    _cubit.loadAll();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _pickMonth(DashboardV2State state) async {
    HapticFeedback.selectionClick();
    final m = await showMonthPickerV2(context, initialMonth: state.month);
    if (m != null) _cubit.changeMonth(m);
  }

  /// Bấm ô đơn từ → mở danh sách đơn tương ứng (web cũng mở danh sách khi số > 0).
  void _openRequestList(DashboardCount item) {
    if (item.count <= 0) return;
    final Widget? page = switch (item.key) {
      'leave' => const OnLeavePageV2(isFromHome: true),
      'overtime' => const OvertimePageV2(isFromHome: true),
      'late_early' => const JustificationPageV2(isFromHome: true),
      'business_trip' => const WorkTripPageV2(isFromHome: true),
      _ => null, // WFH: app chưa có màn danh sách
    };
    if (page == null) return;
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openAll(String title, List<Widget> rows) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DashboardListPageV2(title: title, rows: rows)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<DashboardV2Cubit, DashboardV2State>(
            bloc: _cubit,
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: StaggerRevealV2(index: 0, child: _topBar(state)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cubit.loadAll,
                      color: AppTokensV2.accent,
                      backgroundColor: AppTokensV2.bgTop,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        children: [
                          _requestsCard(state),
                          if (state.pending?.hasSubordinates == true) ...[
                            const SizedBox(height: 12),
                            _pendingCard(state),
                          ],
                          const SizedBox(height: 12),
                          _behaviourCard(state),
                          const SizedBox(height: 12),
                          _headcountCard(state),
                          const SizedBox(height: 12),
                          _birthdaysCard(state),
                          const SizedBox(height: 12),
                          _alertsCard(state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _topBar(DashboardV2State state) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text('Dashboard',
            style: AppTokensV2.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      // Bộ lọc "Tháng" như web (12 tháng của năm hiện tại).
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pickMonth(state),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_month_rounded, size: 16, color: AppTokensV2.accent),
            const SizedBox(width: 6),
            Text(S.of(context).v2_main_month_year_short(state.month, state.year),
                style: AppTokensV2.captionStrong),
            Icon(Icons.expand_more_rounded, size: 18, color: AppTokensV2.fgSoft),
          ]),
        ),
      ),
    ]);
  }

  // ───────────────────────── Các thẻ ─────────────────────────

  Widget _requestsCard(DashboardV2State state) {
    final data = state.requests;
    return _section(
      title: _titleOr(data?.title, S.of(context).v2_main_dash_my_requests),
      status: state.requestsStatus,
      hasData: data != null,
      child: () => _countGrid(data!.items, onTap: _openRequestList),
    );
  }

  Widget _pendingCard(DashboardV2State state) {
    final data = state.pending!;
    return _section(
      title: _titleOr(data.title, S.of(context).v2_main_dash_pending_requests),
      badge: S.of(context).v2_main_request_count(data.total),
      status: state.pendingStatus,
      hasData: true,
      child: () => _countGrid(data.items),
    );
  }

  Widget _headcountCard(DashboardV2State state) {
    final data = state.headcount;
    return _section(
      title: _titleOr(data?.title, S.of(context).v2_main_dash_headcount),
      status: state.headcountStatus,
      hasData: data != null,
      child: () => _countGrid(data!.items, perRow: 4),
    );
  }

  Widget _behaviourCard(DashboardV2State state) {
    final data = state.behaviour;
    return _section(
      title: _titleOr(data?.title, S.of(context).v2_main_dash_behaviour),
      status: state.behaviourStatus,
      hasData: data != null,
      child: () {
        final items = data!.items;
        if (items.isEmpty) return _empty(S.of(context).justification_emptyData);
        final maxCount = items.fold<int>(0, (m, e) => e.count > m ? e.count : m);
        return Column(children: [
          Row(children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _behaviourPill(items[i])),
            ],
          ]),
          const SizedBox(height: 14),
          for (final item in items) _behaviourBar(item, maxCount),
        ]);
      },
    );
  }

  Widget _birthdaysCard(DashboardV2State state) {
    final data = state.birthdays;
    final people = data?.items ?? const <BirthdayPerson>[];
    final title =
        _titleOr(data?.title, S.of(context).appraisal_birthday_month_title);
    return _section(
      title: title,
      badge: data == null ? null : '${people.length}',
      status: state.birthdaysStatus,
      hasData: data != null,
      child: () {
        if (people.isEmpty) return _empty(S.of(context).v2_main_dash_no_birthdays);
        final rows = people.map(_birthdayRow).toList();
        return _previewList(rows, () => _openAll(title, rows));
      },
    );
  }

  Widget _alertsCard(DashboardV2State state) {
    final data = state.alerts;
    final alerts = data?.items ?? const <AttendanceAlert>[];
    final title = _titleOr(data?.title, S.of(context).v2_main_dash_alerts);
    return _section(
      title: title,
      badge: data == null ? null : '${alerts.length}',
      status: state.alertsStatus,
      hasData: data != null,
      child: () {
        if (alerts.isEmpty) return _empty(S.of(context).v2_main_dash_no_alerts);
        final rows = alerts.map(_alertRow).toList();
        return _previewList(rows, () => _openAll(title, rows));
      },
    );
  }

  // ───────────────────────── Thành phần ─────────────────────────

  /// Tiêu đề thẻ: server gửi sẵn tiêu đề tiếng Việt (giống web) → chỉ dùng khi app đang ở
  /// tiếng Việt; ngôn ngữ khác dùng nhãn của app.
  String _titleOr(String? title, String fallback) =>
      (title == null ||
              title.isEmpty ||
              Localizations.localeOf(context).languageCode != 'vi')
          ? fallback
          : title;

  /// Nhãn ô / thanh theo mã cố định của API /dashboard/* (nodo_hr_api dashboard_handle):
  /// tiếng Việt giữ nhãn server (giống web); ngôn ngữ khác dịch theo mã, mã lạ hiện nhãn server.
  String _keyLabel(String key, String serverLabel, {bool chart = false}) {
    if (Localizations.localeOf(context).languageCode == 'vi') return serverLabel;
    final s = S.of(context);
    return switch (key) {
      'leave' => s.v2_dash_key_leave,
      'overtime' => s.v2_dash_key_overtime,
      'late_early' => s.v2_dash_key_late_early,
      'muon_som' => chart ? s.v2_dash_key_late_early_chart : s.v2_dash_key_late_early,
      'business_trip' => s.v2_dash_key_business_trip,
      'wfh' => s.v2_dash_key_wfh,
      'total' => s.v2_dash_key_total,
      'official' => s.v2_dash_key_official,
      'probation' => s.v2_dash_key_probation,
      'intern' => s.v2_dash_key_intern,
      'quen_cham_cong' => s.v2_dash_key_missed_check,
      'thieu_gio' => s.v2_dash_key_missing_in_out,
      _ => serverLabel,
    };
  }

  Widget _section({
    required String title,
    String? badge,
    required LoadStatus status,
    required bool hasData,
    required Widget Function() child,
  }) {
    Widget body;
    if (status == LoadStatus.FAILURE) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _cubit.loadAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Icon(Icons.refresh_rounded, size: 18, color: AppTokensV2.fgMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(S.of(context).v2_main_dash_load_failed,
                  style: AppTokensV2.caption),
            ),
          ]),
        ),
      );
    } else if (!hasData) {
      body = SizedBox(
        height: 56,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTokensV2.accent),
          ),
        ),
      );
    } else {
      body = child();
    }

    return GlassCardV2(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: AppTokensV2.section)),
          if (status == LoadStatus.LOADING && hasData)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.8, color: AppTokensV2.accent),
            )
          else if (badge != null)
            _badge(badge),
        ]),
        const SizedBox(height: 12),
        body,
      ]),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppTokensV2.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              color: AppTokensV2.accent, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: AppTokensV2.caption),
      );

  /// Lưới ô đếm (giá trị 2 chữ số như web: "00", "03").
  Widget _countGrid(
    List<DashboardCount> items, {
    int perRow = 3,
    void Function(DashboardCount)? onTap,
  }) {
    if (items.isEmpty) return _empty(S.of(context).justification_emptyData);
    return LayoutBuilder(builder: (context, c) {
      const gap = 8.0;
      final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final item in items)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap == null ? null : () => onTap(item),
              child: Container(
                width: w,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  color: AppTokensV2.surfaceStrong,
                  border: Border.all(color: AppTokensV2.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(children: [
                  Text(item.count.toString().padLeft(2, '0'),
                      style: AppTokensV2.number.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(_keyLabel(item.key, item.label),
                      style: AppTokensV2.caption,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
        ],
      );
    });
  }

  Widget _behaviourPill(BehaviourItem item) {
    final color = _hex(item.color, AppTokensV2.danger);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Text('${item.count}',
            style: AppTokensV2.number.copyWith(fontSize: 22, color: color)),
        const SizedBox(height: 2),
        Text(_keyLabel(item.key, item.label),
            style: AppTokensV2.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  /// Thanh ngang như biểu đồ của web ("{n} lần").
  Widget _behaviourBar(BehaviourItem item, int maxCount) {
    final color = _hex(item.color, AppTokensV2.danger);
    final factor = maxCount <= 0 ? 0.0 : item.count / maxCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 104,
          child: Text(_keyLabel(item.key, item.chartLabel, chart: true),
              style: AppTokensV2.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(children: [
              Container(height: 10, color: AppTokensV2.surfaceStrong),
              FractionallySizedBox(
                widthFactor: factor.clamp(0.0, 1.0),
                child: Container(height: 10, color: color),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          // Tiếng Anh dài hơn ("12 times") → thu nhỏ chữ cho vừa ô thay vì xuống dòng.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(S.of(context).v2_main_times_count(item.count),
                style: AppTokensV2.caption, textAlign: TextAlign.right),
          ),
        ),
      ]),
    );
  }

  Widget _previewList(List<Widget> rows, VoidCallback openAll) {
    final shown = rows.take(_previewCount).toList();
    return Column(children: [
      ...shown,
      if (rows.length > _previewCount)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: openAll,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(S.of(context).v2_main_see_all_count(rows.length),
                style: TextStyle(
                    color: AppTokensV2.accent, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
        ),
    ]);
  }

  Widget _birthdayRow(BirthdayPerson p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        _avatar(p),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                style: AppTokensV2.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (p.dept.isNotEmpty)
              Text(p.dept,
                  style: AppTokensV2.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(p.dob, style: AppTokensV2.captionStrong),
          if (p.wished)
            Text(S.of(context).v2_main_dash_wished,
                style: TextStyle(
                    color: AppTokensV2.success, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  Widget _avatar(BirthdayPerson p) {
    final parts = p.name.trim().split(RegExp(r'\s+'));
    final initials = parts.isEmpty || parts.first.isEmpty
        ? '?'
        : (parts.length == 1
                ? parts.first.characters.first
                : parts.first.characters.first + parts.last.characters.first)
            .toUpperCase();
    final fallback = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppTokensV2.accentGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(initials,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    );
    final uri = Uri.tryParse(p.avatar);
    if (p.avatar.isEmpty || uri == null || !uri.hasScheme) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: p.avatar,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }

  Widget _alertRow(AttendanceAlert a) {
    final color = _hex(
      a.dotColor,
      switch (a.level) {
        'danger' => AppTokensV2.danger,
        'warning' => AppTokensV2.warn,
        _ => AppTokensV2.success,
      },
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title, style: AppTokensV2.body),
            if (a.description.isNotEmpty) Text(a.description, style: AppTokensV2.caption),
          ]),
        ),
      ]),
    );
  }

  /// "#E24B4A" → Color; sai định dạng thì dùng [fallback].
  static Color _hex(String hex, Color fallback) {
    final h = hex.replaceFirst('#', '');
    if (h.length != 6) return fallback;
    final v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(0xFF000000 | v);
  }
}

/// Trang "Xem tất cả" cho thẻ Sinh nhật / Cảnh báo chuyên cần.
class _DashboardListPageV2 extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _DashboardListPageV2({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Row(children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.maybePop(context),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTokensV2.fg, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: AppTokensV2.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  GlassCardV2(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(children: rows),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
