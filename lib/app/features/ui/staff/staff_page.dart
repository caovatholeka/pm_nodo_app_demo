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
import 'package:pm_app/app/features/widgets/app_cached_image.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart' as widgets;
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
  final _scrollThreshold = 100.0;
  bool _isSearchActive = false;

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
      if (_searchController.text.trim().isEmpty) {
        _cubit.getListEmployees();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onMaxScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMaxScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _cubit.onLoadMore();
    }
  }

Future<void> _openFilterSheet() async {
  final departments = await MasterData.getDepartmentsFromApi();
  final jobTitles = await MasterData.getJobTitlesFromApi();
  final statuses = MasterData.employeeStatuses;

  final savedFilter = _cubit.state.filterParam;

  final nameController = TextEditingController(text: savedFilter?.name ?? '');
  final codeController = TextEditingController(text: savedFilter?.code ?? '');
  final emailController = TextEditingController(text: savedFilter?.email ?? '');

  int? selectedDeptId = savedFilter?.departmentId;
  String? selectedJob = savedFilter?.jobTitle;
  String? selectedStatus;

  if (savedFilter?.active == true) {
    selectedStatus = "Đang làm việc";
  } else if (savedFilter?.active == false) {
    selectedStatus = "Đã nghỉ việc";
  } else {
    selectedStatus = null;
  }

  if (!mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 12,
          left: 16,
          right: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bộ lọc nâng cao",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          nameController.clear();
                          codeController.clear();
                          emailController.clear();
                          selectedDeptId = null;
                          selectedJob = null;
                          selectedStatus = null;
                          _cubit.clearFilter();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Xóa lọc",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  InputTextField(
                    title: "Tên nhân viên",
                    hintText: "Nhập tên nhân viên",
                    isRequiredField: false,
                    controller: nameController,
                    enable: true,
                  ),
                  const SizedBox(height: 10),
                  InputTextField(
                    title: "Mã nhân viên",
                    hintText: "Nhập mã nhân viên",
                    isRequiredField: false,
                    controller: codeController,
                    enable: true,
                  ),
                  widgets.DropdownInputField(
                    title: "Phòng ban",
                    hint: "Chọn phòng ban",
                    items: ["Không", ...departments.map((e) => e.text ?? "")],
                    selectedValue: selectedDeptId == null
                        ? "Không"
                        : departments
                            .firstWhere(
                              (d) => d.id == selectedDeptId,
                              orElse: () =>
                                  const MasterDataItem(text: "Không"),
                            )
                            .text,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == "Không") {
                          selectedDeptId = null;
                        } else {
                          final selected = departments.firstWhere(
                            (d) => d.text == val,
                            orElse: () =>
                                const MasterDataItem(text: "Không"),
                          );
                          selectedDeptId = selected.id;
                        }
                      });
                    },
                  ),
                  widgets.DropdownInputField(
                    title: "Chức vụ",
                    hint: "Chọn chức vụ",
                    items: ["Không", ...jobTitles.map((e) => e.text ?? "")],
                    selectedValue: selectedJob ?? "Không",
                    onChanged: (val) {
                      setModalState(() {
                        if (val == "Không") {
                          selectedJob = null;
                        } else {
                          final selected = jobTitles.firstWhere(
                            (j) => j.text == val,
                            orElse: () =>
                                const MasterDataItem(text: "Không"),
                          );
                          selectedJob = selected.name;
                        }
                      });
                    },
                  ),
                  InputTextField(
                    title: "Email",
                    hintText: "Nhập email",
                    controller: emailController,
                    isRequiredField: false,
                    enable: true,
                  ),
                  widgets.DropdownInputField(
                    title: "Trạng thái",
                    hint: "Chọn trạng thái",
                    items: ["Không", ...statuses],
                    selectedValue: selectedStatus ?? "Không",
                    onChanged: (val) {
                      setModalState(() {
                        selectedStatus = (val == "Không") ? null : val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final activeValue = selectedStatus == "Đang làm việc"
                            ? true
                            : selectedStatus == "Đã nghỉ việc"
                                ? false
                                : null;
                        final filter = EmployeeFilterParam(
                          name: nameController.text.isNotEmpty
                              ? nameController.text
                              : null,
                          code: codeController.text.isNotEmpty
                              ? codeController.text
                              : null,
                          email: emailController.text.isNotEmpty
                              ? emailController.text
                              : null,
                          departmentId: selectedDeptId,
                          jobTitle: selectedJob,
                          active: activeValue,
                        );
                        _cubit.filterEmployees(filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0062FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}



  void _onSearchPressed() {
    final query = _searchController.text.trim();
    _cubit.searchEmployees(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(
        titleAppbar: "Danh sách nhân viên",
        haveBackButton: (widget.isFromHome ?? false),
        haveActionButton: true,
        iconPathAsset: AppAssets.ic_bell,
        actionCallBack: () {},
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.imgBg2, fit: BoxFit.cover),
          ),
          SafeArea(
            child: BlocBuilder<StaffCubit, StaffState>(
              bloc: _cubit,
              buildWhen: (prev, cur) =>
                  prev.loadStatus != cur.loadStatus ||
                  prev.listEmployees != cur.listEmployees ||
                  prev.loadEventStatus != cur.loadEventStatus,
              builder: (context, state) {
                if (state.loadStatus == LoadStatus.LOADING) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.loadStatus == LoadStatus.FAILURE) {
                  return const Center(
                      child: Text("Không thể tải danh sách nhân viên"));
                }

                final employees = state.listEmployees ?? [];
                final isShowLoadMore =
                    state.loadEventStatus == LoadStatus.LOADING_MORE;

                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Colors.grey, size: 22),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: "Mã nhân viên, Tên nhân viên",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _onSearchPressed(),
                                ),
                              ),
                              InkWell(
                                onTap: _onSearchPressed,
                                borderRadius: BorderRadius.circular(8),
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
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0062FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
Expanded(
  child: employees.isEmpty
      ? Center(
          child: Text(
            state.filterParam != null
                ? "Không có kết quả nào phù hợp với bộ lọc"
                : "Không có nhân viên nào",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        )
      : Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                
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
                        url: emp.avatarUrl ?? "",
                        size: 58,
                      ),
                      title: Text(
                        emp.name ?? "Không có tên",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Phòng ban: ${emp.department ?? 'Chưa có'}\n${emp.jobTitle ?? ''}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      trailing: Text(
                        emp.code != null ? "NV${emp.code}" : "",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 98, 255),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeDetailPage(
                              employeeId: emp.id ?? 0,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            if (isShowLoadMore)
              const Align(
                alignment: Alignment.bottomCenter,
                child: LoadingMoreRowWidget(),
              ),
          ],
        ),
),
                        const SizedBox(height: 60,),

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
}
