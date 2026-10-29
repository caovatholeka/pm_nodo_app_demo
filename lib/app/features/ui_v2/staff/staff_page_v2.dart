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
import 'package:pm_app/app/data/local/master_data.dart';
import 'package:pm_app/app/data/models/entities/employee_entity.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/ui_v2/staff/staff_detail_page_v2.dart';
import 'package:pm_app/app/features/ui_v2/widgets/advanced_filter_sheet_v2.dart';
import 'package:pm_app/generated/l10n.dart';

/// Màn Nhân viên — giao diện tối (v2).
///
/// Trình bày dạng **lưới 2 cột** (dễ quét bằng mắt hơn danh sách dọc) kèm hàng
/// **badge lọc nhanh theo phòng ban**. Chức năng giữ nguyên bản cũ: tìm kiếm,
/// lọc nâng cao, cuộn tải thêm, chạm mở chi tiết. Tái dùng [StaffCubit].
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

  /// Phòng ban cho badge lọc nhanh; null = chưa tải xong.
  List<MasterDataItem>? _departments;

  /// Phòng ban đang chọn ở badge; null = "Tất cả".
  int? _selectedDeptId;

  @override
  void initState() {
    super.initState();
    _cubit.getListEmployees();
    _scroll.addListener(_onScroll);
    _search.addListener(() {
      if (_search.text.trim().isEmpty) {
        _activeFilter = null;
        _selectedDeptId = null;
        _cubit.getListEmployees();
        setState(() {});
      }
    });
    _loadDepartments();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final list = await MasterData.getDepartmentsFromApi();
      if (!mounted) return;
      setState(() => _departments = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _departments = const []);
    }
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 100) {
      _cubit.onLoadMore();
    }
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    _cubit.getListEmployees(query: _search.text.trim());
  }

  /// Chọn badge phòng ban: null = tất cả.
  void _selectDepartment(int? id) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDeptId = id;
      _activeFilter = id == null ? null : EmployeeFilterParam(departmentId: id);
    });
    _cubit.getListEmployees(filter: _activeFilter);
  }

  Future<void> _openFilter() async {
    final departments = await MasterData.getDepartmentsFromApi();
    final jobTitles = await MasterData.getJobTitlesFromApi();
    final statuses = MasterData.employeeStatuses;
    if (!mounted) return;

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTokensV2.bgTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdvancedFilterSheetV2(
        departments: departments,
        jobTitles: jobTitles,
        statuses: statuses,
        savedFilter: _activeFilter,
      ),
    );

    if (result == 'clear_filter') {
      setState(() {
        _activeFilter = null;
        _selectedDeptId = null;
      });
      _cubit.getListEmployees(filter: null);
      return;
    }
    if (result is EmployeeFilterParam) {
      setState(() {
        _activeFilter = result;
        // Badge chỉ sáng khi bộ lọc đúng là "lọc theo 1 phòng ban".
        _selectedDeptId = result.departmentId;
      });
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
            const SizedBox(height: 12),
            StaggerRevealV2(index: 2, child: _departmentBadges()),
            const SizedBox(height: 4),
            Expanded(
              child: BlocBuilder<StaffCubit, StaffState>(
                bloc: _cubit,
                builder: (context, state) => _grid(state),
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
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTokensV2.fg, size: 20),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Text(s.employee_title,
            style: AppTokensV2.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
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
            Icon(Icons.search_rounded,
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
                child: Icon(Icons.close_rounded,
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

  /// Hàng badge lọc nhanh theo phòng ban (cuộn ngang).
  Widget _departmentBadges() {
    final depts = _departments;
    if (depts == null) {
      return const SizedBox(height: 38); // giữ chỗ trong lúc tải
    }
    if (depts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: depts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _badge(S.of(context).notifications_all, _selectedDeptId == null,
                () => _selectDepartment(null));
          }
          final d = depts[i - 1];
          final label = (d.name ?? d.text ?? '').trim();
          if (label.isEmpty) return const SizedBox.shrink();
          return _badge(label, _selectedDeptId == d.id,
              () => _selectDepartment(d.id));
        },
      ),
    );
  }

  Widget _badge(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTokensV2.dFast,
        curve: AppTokensV2.easeExpo,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppTokensV2.accent.withValues(alpha: 0.22)
              : AppTokensV2.surfaceStrong,
          border: Border.all(
              color: selected ? AppTokensV2.accent : AppTokensV2.border),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTokensV2.accent : AppTokensV2.fgSoft,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _grid(StaffState state) {
    final list = state.listEmployees ?? const <EmployeeEntity>[];

    if (state.loadStatus == LoadStatus.LOADING && list.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.2, color: AppTokensV2.accent),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.people_outline_rounded,
                size: 44, color: AppTokensV2.fgMuted),
            const SizedBox(height: 10),
            Text(S.of(context).v2_main_no_employees,
                style: AppTokensV2.captionStrong),
          ]),
        ),
      );
    }

    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _employeeTile(list[i]),
    );
  }

  Widget _employeeTile(EmployeeEntity emp) {
    final s = S.of(context);
    final dept = (emp.department ?? '').trim();
    final job = (emp.jobTitle ?? '').trim();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffDetailPageV2(employeeId: emp.id ?? 0),
          ),
        );
      },
      child: GlassCardV2(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        radius: 18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _avatar(emp.avatarUrl, emp.name ?? '-'),
            const SizedBox(height: 10),
            Text(
              emp.name ?? '-',
              style: AppTokensV2.body.copyWith(fontSize: 13.5),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (job.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(job,
                  style: AppTokensV2.caption,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
            const Spacer(),
            if (dept.isNotEmpty)
              Text('${s.employee_card_department}: $dept',
                  style: AppTokensV2.captionStrong.copyWith(fontSize: 10.5),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            if (emp.code != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTokensV2.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${s.employee_card_id}:${emp.code}',
                    style: AppTokensV2.caption.copyWith(
                        color: AppTokensV2.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
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
        width: 62,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppTokensV2.accentGradient, shape: BoxShape.circle),
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800)),
      );
    }

    return ClipOval(
      child: valid
          ? CachedNetworkImage(
              imageUrl: raw!,
              width: 62,
              height: 62,
              fit: BoxFit.cover,
              placeholder: (_, __) => fallback(),
              errorWidget: (_, __, ___) => fallback(),
            )
          : fallback(),
    );
  }
}
