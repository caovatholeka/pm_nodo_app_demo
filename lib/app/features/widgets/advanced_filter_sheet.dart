import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart'
    as widgets;

class AdvancedFilterSheet extends StatefulWidget {
  final List<MasterDataItem> departments;
  final List<MasterDataItem> jobTitles;
  final List<String> statuses;
  final EmployeeFilterParam? savedFilter;

  const AdvancedFilterSheet({
    super.key,
    required this.departments,
    required this.jobTitles,
    required this.statuses,
    this.savedFilter,
  });

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
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

  void _syncInitialFilter() {
    final f = widget.savedFilter;

    if (f == null) {
      setState(() {
        nameController.text = "";
        codeController.text = "";
        emailController.text = "";
        selectedDeptId = null;
        selectedJobId = null;
        selectedStatus = null;
      });
      return;
    }

    setState(() {
      nameController.text = f.name ?? "";
      codeController.text = f.code ?? "";
      emailController.text = f.email ?? "";
      selectedDeptId = f.departmentId;
      selectedJobId = f.jobTitleId;

      if (f.active == true) {
        selectedStatus = "Đang làm việc";
      } else if (f.active == false) {
        selectedStatus = "Đã nghỉ việc";
      } else {
        selectedStatus = null;
      }
    });
  }

  void _clearFilters() {
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
    final active =
        selectedStatus == "Đang làm việc"
            ? true
            : selectedStatus == "Đã nghỉ việc"
            ? false
            : null;

    final filter = EmployeeFilterParam(
      name:
          nameController.text.trim().isNotEmpty
              ? nameController.text.trim()
              : null,
      code:
          codeController.text.trim().isNotEmpty
              ? codeController.text.trim()
              : null,
      email:
          emailController.text.trim().isNotEmpty
              ? emailController.text.trim()
              : null,
      departmentId: selectedDeptId,
      jobTitleId: selectedJobId,
      active: active,
    );

    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.black87,
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Bộ lọc nâng cao",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: _clearFilters,
                    child: const Text(
                      "Xóa lọc",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED)),
            const SizedBox(height: 16),

            InputTextField(
              title: "Tên nhân viên",
              hintText: "Nhập tên nhân viên",
              controller: nameController,
              isRequiredField: false,
            ),
            const SizedBox(height: 10),

            InputTextField(
              title: "Mã nhân viên",
              hintText: "Nhập mã nhân viên",
              controller: codeController,
              isRequiredField: false,
            ),

            widgets.DropdownInputField(
              title: "Phòng ban",
              hint: "Chọn phòng ban",
              items: widget.departments.map((e) => e.text ?? "").toList(),
              selectedValue:
                  selectedDeptId == null
                      ? null
                      : widget.departments
                          .firstWhere((d) => d.id == selectedDeptId)
                          .text,
              onChanged: (val) {
                setState(() {
                  selectedDeptId =
                      val == null || val.isEmpty
                          ? null
                          : widget.departments
                              .firstWhere((d) => d.text == val)
                              .id;
                });
              },
            ),

            widgets.DropdownInputField(
              title: "Chức vụ",
              hint: "Chọn chức vụ",
              items: widget.jobTitles.map((e) => e.text ?? "").toList(),
              selectedValue:
                  selectedJobId == null
                      ? null
                      : widget.jobTitles
                          .firstWhere((j) => j.id == selectedJobId)
                          .text,
              onChanged: (val) {
                setState(() {
                  selectedJobId =
                      val == null || val.isEmpty
                          ? null
                          : widget.jobTitles
                              .firstWhere((j) => j.text == val)
                              .id;
                });
              },
            ),

            InputTextField(
              title: "Email",
              hintText: "Nhập email",
              controller: emailController,
              isRequiredField: false,
            ),

            widgets.DropdownInputField(
              title: "Trạng thái",
              hint: "Chọn trạng thái",
              items: widget.statuses,
              selectedValue: selectedStatus,
              onChanged: (val) {
                setState(() {
                  selectedStatus = (val?.isEmpty ?? true) ? null : val;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0062FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Áp dụng",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
