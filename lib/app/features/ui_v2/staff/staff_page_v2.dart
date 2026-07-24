import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui/staff/staff_detail_page.dart';
import 'package:pm_app/app/features/widgets/advanced_filter_sheet.dart';
import 'package:pm_app/app/data/local/master_data.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Nhân viên — giao diện tối (v2). Nội dung giữ nguyên bản cũ:
/// tìm kiếm, lọc nâng cao, danh sách nhân viên (avatar/tên/phòng ban/chức danh/mã),
/// cuộn xuống tải thêm, chạm để mở chi tiết. Tái dùng [StaffCubit].
class StaffPageV2 extends StatefulWidget {
  final bool? isFromHome;
  const StaffPageV2({super.key, this.isFromHome});

  @override
  State<StaffPageV2> createState() => _StaffPageV2State();
}

class _StaffPageV2State extends State<StaffPageV2> {
  final StaffCubit _cubit = GetIt.I.get<StaffCubit>();
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  EmployeeFilterParam? _activeFilter;

  @override
  void initState() {
    super.initState();
    _cubit.getListEmployees();
    _scroll.addListener(_onScroll);
    _search.addListener(() {
      if (_search.text.trim().isEmpty) {
        _activeFilter = null;
        _cubit.getListEmployees();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 100) {
      _cubit.onLoadMore();
    }
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    _cubit.getListEmployees(query: _search.text.trim());
  }

  Future<void> _openFilter() async {
    final departments = await MasterData.getDepartmentsFromApi();
    final jobTitles = await MasterData.getJobTitlesFromApi();
    final statuses = MasterData.employeeStatuses;
    if (!mounted) return;

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdvancedFilterSheet(
        departments: departments,
        jobTitles: jobTitles,
        statuses: statuses,
        savedFilter: _activeFilter,
      ),
    );

    if (result == 'clear_filter') {
      setState(() => _activeFilter = null);
      _cubit.getListEmployees(filter: null);
      return;
    }
    if (result is EmployeeFilterParam) {
      setState(() => _activeFilter = result);
      _cubit.getListEmployees(filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppTokensV2.bgDeep,
      body: AmbientBackgroundV2(
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: StaggerRevealV2(index: 0, child: _topBar(s)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: StaggerRevealV2(index: 1, child: _searchBar(s)),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BlocBuilder<StaffCubit, StaffState>(
                bloc: _cubit,
                builder: (context, state) => _list(state),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(S s) {
    final showBack = widget.isFromHome ?? false;
    return Row(children: [
      if (showBack) ...[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg, size: 20),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Text(s.employee_title,
            style: AppTokensV2.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _searchBar(S s) {
    final hasFilter = _activeFilter != null;
    return Row(children: [
      Expanded(
        child: GlassCardV2(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          radius: 15,
          child: Row(children: [
            const Icon(Icons.search_rounded,
                size: 19, color: AppTokensV2.fgMuted),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: _search,
                style: AppTokensV2.body.copyWith(fontSize: 13.5),
                cursorColor: AppTokensV2.accent,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submitSearch(),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintText: s.employee_search_hint,
                  hintStyle: AppTokensV2.caption,
                ),
              ),
            ),
            if (_search.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _search.clear();
                  FocusScope.of(context).unfocus();
                },
                child: const Icon(Icons.close_rounded,
                    size: 17, color: AppTokensV2.fgMuted),
              ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          _openFilter();
        },
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasFilter
                ? AppTokensV2.accent.withValues(alpha: 0.20)
                : AppTokensV2.surfaceStrong,
            border: Border.all(
                color: hasFilter ? AppTokensV2.accent : AppTokensV2.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.tune_rounded,
              size: 20,
              color: hasFilter ? AppTokensV2.accent : AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _list(StaffState state) {
    final list = state.listEmployees ?? const <EmployeeEntity>[];

    if (state.loadStatus == LoadStatus.LOADING && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.2, color: AppTokensV2.accent),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people_outline_rounded,
                size: 44, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text('Không có nhân viên', style: AppTokensV2.captionStrong),
          ]),
        ),
      );
    }

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _employeeCard(list[i]),
    );
  }

  Widget _employeeCard(EmployeeEntity emp) {
    final s = S.of(context);
    final dept = emp.department ?? '-';
    final job = emp.jobTitle ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffDetailPage(employeeId: emp.id ?? 0),
          ),
        );
      },
      child: GlassCardV2(
        padding: const EdgeInsets.all(12),
        radius: 17,
        child: Row(children: [
          _avatar(emp.avatarUrl, emp.name ?? '-'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.name ?? '-',
                    style: AppTokensV2.body.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${s.employee_card_department}: $dept',
                    style: AppTokensV2.captionStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (job.isNotEmpty)
                  Text(job,
                      style: AppTokensV2.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (emp.code != null) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTokensV2.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${s.employee_card_id}:${emp.code}',
                  style: AppTokensV2.caption.copyWith(
                      color: AppTokensV2.accent,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _avatar(String? url, String name) {
    final raw = url?.trim();
    final uri = (raw == null || raw.isEmpty) ? null : Uri.tryParse(raw);
    final valid = uri != null && uri.hasScheme && uri.host.isNotEmpty;

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
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            gradient: AppTokensV2.accentGradient, shape: BoxShape.circle),
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );
    }

    return ClipOval(
      child: valid
          ? CachedNetworkImage(
              imageUrl: raw!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) => fallback(),
              errorWidget: (_, __, ___) => fallback(),
            )
          : fallback(),
    );
  }
}
