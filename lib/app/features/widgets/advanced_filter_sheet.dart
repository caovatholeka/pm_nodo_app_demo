import 'package:flutter/material.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/core/param/employee_filter_param.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';
import 'package:pm_app/app/features/widgets/dropdown_input_field.dart' as widgets;
import 'package:pm_app/generated/l10n.dart';

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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22, color: Colors.black87),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        s.employee_advanced_filter,
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
                    child:Text(
                      s.employee_advanced_delete,
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
              title: s.employee_advanced_name,
              hintText: s.employee_advanced_namehint,
              controller: nameController,
              isRequiredField: false,
            ),
            const SizedBox(height: 10),

            InputTextField(
              title: s.employee_advanced_code,
              hintText: s.employee_advanced_codehint,
              controller: codeController,
              isRequiredField: false,
            ),
            const SizedBox(height: 10),

            widgets.DropdownInputField(
              title: s.employee_advanced_department,
              hint: s.employee_advanced_select_department,
              items: widget.departments.map((e) => e.text ?? "").toList(),
              selectedValue: selectedDeptId == null
                  ? null
                  : widget.departments.firstWhere((d) => d.id == selectedDeptId).text,
              onChanged: (val) {
                setState(() {
                  selectedDeptId = (val == null || val.isEmpty)
                      ? null
                      : widget.departments.firstWhere((d) => d.text == val).id;
                });
              },
            ),
            const SizedBox(height: 10),

            widgets.DropdownInputField(
              title: s.employee_advanced_position,
              hint: s.employee_advanced_select_position,
              items: widget.jobTitles.map((e) => e.text ?? "").toList(),
              selectedValue: selectedJobId == null
                  ? null
                  : widget.jobTitles.firstWhere((j) => j.id == selectedJobId).text,
              onChanged: (val) {
                setState(() {
                  selectedJobId = (val == null || val.isEmpty)
                      ? null
                      : widget.jobTitles.firstWhere((j) => j.text == val).id;
                });
              },
            ),
            const SizedBox(height: 10),

            InputTextField(
              title: "Email",
              hintText: s.employee_advanced_emailhint,
              controller: emailController,
              isRequiredField: false,
            ),
            const SizedBox(height: 10),

            widgets.DropdownInputField(
              title: s.employee_advanced_status,
              hint: s.employee_advanced_select_status,
              items: widget.statuses,              
              selectedValue: selectedStatus,
              onChanged: (val) {
                setState(() {
                  selectedStatus = val;            
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
                child:Text(
                  s.employee_advanced_apply,
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
