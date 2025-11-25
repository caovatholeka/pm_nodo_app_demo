import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/data/local/master_data.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/staff/employee_detail_page.dart';
import 'package:pm_app/app/features/ui/staff/staff_cubit.dart';
import 'package:pm_app/app/features/widgets/advanced_filter_sheet.dart';
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import '../../widgets/loading_more_row_widget.dart';

class StaffPage extends StatefulWidget {
  final bool? isFromHome;
  const StaffPage({super.key, this.isFromHome});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final _cubit = GetIt.I.get<StaffCubit>();
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final double _scrollThreshold = 100;
  bool _isSearchActive = false;

  EmployeeFilterParam? _activeFilter; 

  @override
  void initState() {
    super.initState();

    if (_cubit.state.listEmployees == null ||
        _cubit.state.listEmployees!.isEmpty) {
      _cubit.getListEmployees();
    }

    _scrollController.addListener(_onMaxScroll);

    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      if (hasText != _isSearchActive) {
        setState(() => _isSearchActive = hasText);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMaxScroll() {
    if (_activeFilter != null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final pos = _scrollController.position.pixels;

    if (maxScroll - pos <= _scrollThreshold) {
      _cubit.onLoadMore();
    }
  }

Future<void> _openFilterSheet() async {
  final departments = await MasterData.getDepartmentsFromApi();
  final jobTitles = await MasterData.getJobTitlesFromApi();
  final statuses = MasterData.employeeStatuses;

  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return AdvancedFilterSheet(
        departments: departments,
        jobTitles: jobTitles,
        statuses: statuses,
        savedFilter: _activeFilter,
      );
    },
  );

  if (result == "clear_filter") {
    _activeFilter = null;   
    _cubit.getListEmployees(filter: null);
    return;
  }

  if (result is EmployeeFilterParam) {
    _activeFilter = result; 
    _cubit.getListEmployees(filter: result);
  }
}

  void _onSearchPressed() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _activeFilter = null;
    _cubit.getListEmployees(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Danh sách nhân viên",
        haveBackButton: (widget.isFromHome ?? false),
        haveActionButton: true,
        iconPathAsset: AppAssets.icNotificationBell,
        actionCallBack: () {},
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
          ),
          SafeArea(
            child: BlocBuilder<StaffCubit, StaffState>(
              bloc: _cubit,
              buildWhen: (prev, cur) =>
                  prev.listEmployees != cur.listEmployees ||
                  prev.loadEventStatus != cur.loadEventStatus ||
                  prev.loadStatus != cur.loadStatus,
              builder: (context, state) {
                if (state.loadStatus == LoadStatus.FAILURE) {
                  return const Center(
                      child: Text("Không thể tải danh sách nhân viên"));
                }

                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSearchBar(),
                        Expanded(
                          child: _buildList(
                            employees: state.listEmployees ?? [],
                            state: state,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 6),

          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Mã nhân viên, Tên nhân viên",
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _onSearchPressed(),
            ),
          ),

          InkWell(
            onTap: _onSearchPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 34,
              height: 34,
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                color: _isSearchActive
                    ? const Color.fromARGB(255, 0, 81, 255)
                    : Colors.transparent,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 6),

          InkWell(
            onTap: _openFilterSheet,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF0062FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required List employees,
    required StaffState state,
  }) {
    if (state.loadStatus == LoadStatus.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }

    if (employees.isEmpty) {
      return Center(
        child: Text(
          _activeFilter != null
              ? "Không có kết quả nào phù hợp bộ lọc"
              : "Không có nhân viên nào",
          style: const TextStyle(
              fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            _cubit.getListEmployees(filter: _activeFilter);
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: employees.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final emp = employees[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: AppCircleAvatar(
                    url: emp.avatarUrl ?? AppAssets.img_df_avatar,
                    size: 58,
                  ),
                  title: Text(
                    emp.name ?? "Không có tên",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 15),
                  ),
                  subtitle: Text(
                    "Phòng ban: ${emp.department ?? 'Chưa có'}\n${emp.jobTitle ?? ''}",
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13, height: 1.3),
                  ),
                  trailing: Text(
                    emp.code != null ? "NV${emp.code}" : "",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 98, 255),
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EmployeeDetailPage(employeeId: emp.id ?? 0),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        if (state.loadEventStatus == LoadStatus.LOADING_MORE)
          const Align(
            alignment: Alignment.bottomCenter,
            child: LoadingMoreRowWidget(),
          ),
      ],
    );
  }
}
