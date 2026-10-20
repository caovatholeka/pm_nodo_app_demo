import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/generated/l10n.dart';

/// Bottom sheet "Lọc nâng cao" — bản tối (v2) của [AdvancedFilterSheet].
///
/// Giữ nguyên nghiệp vụ: cùng field lọc, cùng cách map trạng thái UI <-> API,
/// cùng giá trị trả về cho nơi gọi ("clear_filter" | EmployeeFilterParam | null).
/// Chỉ đổi trình bày sang giao diện tối theo `AppTokensV2`.
class AdvancedFilterSheetV2 extends StatefulWidget {
  final List<MasterDataItem> departments;
  final List<MasterDataItem> jobTitles;
  final List<String> statuses;
  final EmployeeFilterParam? savedFilter;

  const AdvancedFilterSheetV2({
    super.key,
    required this.departments,
    required this.jobTitles,
    required this.statuses,
    this.savedFilter,
  });

  @override
  State<AdvancedFilterSheetV2> createState() => _AdvancedFilterSheetV2State();
}

class _AdvancedFilterSheetV2State extends State<AdvancedFilterSheetV2> {
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController emailController;

  int? selectedDeptId;
  int? selectedJobId;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    codeController = TextEditingController();
    emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialFilter();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String? _mapUiToApi(String? uiValue) {
    switch (uiValue) {
      case "Đang làm việc":
        return "work";
      case "Đã nghỉ việc":
        return "stop";
      default:
        return null;
    }
  }

  String? _mapApiToUi(String? apiValue) {
    switch (apiValue) {
      case "work":
        return "Đang làm việc";
      case "stop":
        return "Đã nghỉ việc";
      default:
        return null;
    }
  }

  void _syncInitialFilter() {
    final f = widget.savedFilter;
    if (!mounted) return;

    setState(() {
      nameController.text = f?.name ?? "";
      codeController.text = f?.code ?? "";
      emailController.text = f?.email ?? "";
      selectedDeptId = f?.departmentId;
      selectedJobId = f?.jobTitleId;

      selectedStatus = f?.active != null ? _mapApiToUi(f!.active) : null;
    });
  }

  void _clearFilters() {
    HapticFeedback.selectionClick();
    setState(() {
      nameController.clear();
      codeController.clear();
      emailController.clear();
      selectedDeptId = null;
      selectedJobId = null;
      selectedStatus = null;
    });

    Navigator.pop(context, "clear_filter");
  }

  void _applyFilters() {
    HapticFeedback.selectionClick();
    final filter = EmployeeFilterParam(
      name: nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : null,
      code: codeController.text.trim().isNotEmpty
          ? codeController.text.trim()
          : null,
      email: emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : null,
      departmentId: selectedDeptId,
      jobTitleId: selectedJobId,

      active: _mapUiToApi(selectedStatus),
    );

    Navigator.pop(context, filter);
  }

  Future<void> _pickFromList({
    required String title,
    required List<String> items,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) async {
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppTokensV2.bgTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PickerSheetV2(
        title: title,
        items: items,
        selected: selected,
      ),
    );
    if (result != null) {
      onSelected(result.isEmpty ? null : result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        size: 22, color: AppTokensV2.fgSoft),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        s.employee_advanced_filter,
                        style: AppTokensV2.section,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _clearFilters,
                    child: Text(
                      s.employee_advanced_delete,
                      style: TextStyle(
                        color: AppTokensV2.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: AppTokensV2.border),
            const SizedBox(height: 16),

            _FieldLabelV2(text: s.employee_advanced_name),
            const SizedBox(height: 6),
            _TextInputV2(
              controller: nameController,
              hintText: s.employee_advanced_namehint,
            ),
            const SizedBox(height: 14),

            _FieldLabelV2(text: s.employee_advanced_code),
            const SizedBox(height: 6),
            _TextInputV2(
              controller: codeController,
              hintText: s.employee_advanced_codehint,
            ),
            const SizedBox(height: 14),

            _FieldLabelV2(text: s.employee_advanced_department),
            const SizedBox(height: 6),
            _SelectInputV2(
              hint: s.employee_advanced_select_department,
              value: selectedDeptId == null
                  ? null
                  : widget.departments
                      .firstWhere((d) => d.id == selectedDeptId)
                      .text,
              onTap: () => _pickFromList(
                title: s.employee_advanced_department,
                items: widget.departments.map((e) => e.text ?? "").toList(),
                selected: selectedDeptId == null
                    ? null
                    : widget.departments
                        .firstWhere((d) => d.id == selectedDeptId)
                        .text,
                onSelected: (val) {
                  setState(() {
                    selectedDeptId = (val == null || val.isEmpty)
                        ? null
                        : widget.departments
                            .firstWhere((d) => d.text == val)
                            .id;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),

            _FieldLabelV2(text: s.employee_advanced_position),
            const SizedBox(height: 6),
            _SelectInputV2(
              hint: s.employee_advanced_select_position,
              value: selectedJobId == null
                  ? null
                  : widget.jobTitles
                      .firstWhere((j) => j.id == selectedJobId)
                      .text,
              onTap: () => _pickFromList(
                title: s.employee_advanced_position,
                items: widget.jobTitles.map((e) => e.text ?? "").toList(),
                selected: selectedJobId == null
                    ? null
                    : widget.jobTitles
                        .firstWhere((j) => j.id == selectedJobId)
                        .text,
                onSelected: (val) {
                  setState(() {
                    selectedJobId = (val == null || val.isEmpty)
                        ? null
                        : widget.jobTitles
                            .firstWhere((j) => j.text == val)
                            .id;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),

            _FieldLabelV2(text: "Email"),
            const SizedBox(height: 6),
            _TextInputV2(
              controller: emailController,
              hintText: s.employee_advanced_emailhint,
            ),
            const SizedBox(height: 14),

            _FieldLabelV2(text: s.employee_advanced_status),
            const SizedBox(height: 6),
            _SelectInputV2(
              hint: s.employee_advanced_select_status,
              value: selectedStatus,
              onTap: () => _pickFromList(
                title: s.employee_advanced_status,
                items: widget.statuses,
                selected: selectedStatus,
                onSelected: (val) {
                  setState(() {
                    selectedStatus = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 22),

            PrimaryButtonV2(
              label: s.employee_advanced_apply,
              onTap: _applyFilters,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FieldLabelV2 extends StatelessWidget {
  final String text;
  const _FieldLabelV2({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTokensV2.captionStrong);
  }
}

/// Ô nhập chữ dùng chung: nền `surfaceStrong`, viền `border`, chữ `fg`.
class _TextInputV2 extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _TextInputV2({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: AppTokensV2.surfaceStrong,
        borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
        border: Border.all(color: AppTokensV2.border),
      ),
      child: TextField(
        controller: controller,
        style: AppTokensV2.body,
        cursorColor: AppTokensV2.accent,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintText: hintText,
          hintStyle: AppTokensV2.caption,
        ),
      ),
    );
  }
}

/// Ô chọn (mở picker dạng bottom sheet tối) — thay cho dropdown trắng cũ.
class _SelectInputV2 extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _SelectInputV2({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTokensV2.surfaceStrong,
          borderRadius: BorderRadius.circular(AppTokensV2.radiusSm),
          border: Border.all(color: AppTokensV2.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: hasValue ? AppTokensV2.body : AppTokensV2.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: AppTokensV2.fgMuted),
          ],
        ),
      ),
    );
  }
}

/// Danh sách chọn 1 giá trị, hiển thị trong bottom sheet tối.
/// Trả về `""` khi người dùng chọn "Tất cả" (bỏ lọc), hoặc giá trị đã chọn.
class _PickerSheetV2 extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selected;

  const _PickerSheetV2({
    required this.title,
    required this.items,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: AppTokensV2.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(title, style: AppTokensV2.section),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 1, color: AppTokensV2.border),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, thickness: 1, color: AppTokensV2.border),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selected;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? AppTokensV2.accent
                          : AppTokensV2.fg,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppTokensV2.accent, size: 20)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
