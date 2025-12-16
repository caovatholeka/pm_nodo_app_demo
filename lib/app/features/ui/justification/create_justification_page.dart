import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/ui/justification/widgets/dashed_border_box.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

class CreateJustificationPage extends StatefulWidget {
  const CreateJustificationPage({super.key});

  @override
  State<CreateJustificationPage> createState() =>
      _CreateJustificationPageState();
}

class _CreateJustificationPageState extends State<CreateJustificationPage> {
  final _formKey = GlobalKey<FormState>();

  final _dateCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  final _hourCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final _df = DateFormat("dd/MM/yyyy");

  bool get _canSubmit =>
      _methodCtrl.text.isNotEmpty &&
      _hourCtrl.text.isNotEmpty &&
      _noteCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = _df.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(AppAssets.appBG2, fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: MyAppBar(
            titleAppbar: "Tạo yêu cầu đi muộn về sớm",
            haveBackButton: true,
            haveActionButton: true,
            iconPathAsset: AppAssets.icNotificationBell,
          ),

          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          InputTextField(
                            title: "Loại lý do",
                            hintText: "",
                            isRequiredField: true,
                          ),

                          const SizedBox(height: 16),

                          InputTextField(
                            title: "Ngày",
                            hintText: "Chọn ngày",
                            isRequiredField: true,
                            suffixIcon: AppAssets.icCalendar,
                          ),

                          const SizedBox(height: 16),

                          _blueDashedBox(),

                          const SizedBox(height: 16),

                          InputTextField(
                            title: "Ghi chú",
                            hintText: "Nhập lý do",
                            controller: _noteCtrl,
                            isRequiredField: true,
                            maxLine: 6,
                            onChange: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          bottomSheet: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 48,
                child: PrimaryButton(mainText: "Lưu", callback: () {}),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blueDashedBox() {
    return DashedBorderBox(
      radius: 12,
      color: AppColors.themePrimaryDefault,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InputTextField(
                    title: "Hình thức",
                    hintText: "Hình thức",
                    controller: _methodCtrl,
                    isRequiredField: true,
                    onChange: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputTextField(
                    title: "Số giờ",
                    hintText: "Nhập số giờ",
                    isRequiredField: true,
                    inputType: TextInputType.datetime,
                    onChange: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: AppColors.themePrimaryDefault.withOpacity(
                    0.15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.themePrimaryDefault,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );

    if (res != null) {
      setState(() {
        _dateCtrl.text = _df.format(res);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
  }
}
