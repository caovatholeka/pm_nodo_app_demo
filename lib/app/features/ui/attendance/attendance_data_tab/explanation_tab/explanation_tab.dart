import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

import 'explanation_cubit.dart';

class ExplanationTab extends StatefulWidget {
  const ExplanationTab({super.key});

  @override
  State<ExplanationTab> createState() => _ExplanationTabState();
}

class _ExplanationTabState extends State<ExplanationTab> {
  final TextEditingController _reasonController = TextEditingController();
  final _cubit = GetIt.I.get<ExplanationCubit>();
  bool _isReasonFilled = false;

  @override
  void initState() {
    super.initState();
    _cubit.getListWorkEntries();

    _reasonController.addListener(() {
      final text = _reasonController.text.trim();
      setState(() => _isReasonFilled = text.isNotEmpty);
      _cubit.updateReason(text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplanationCubit, ExplanationState>(
      bloc: _cubit,
      listener: (context, state) {
        try {
          if (state.submitSuccess == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              try {
                showDialog(
                  context: context,
                  builder: (_) => CustomDialog(
                    title: "Thành công",
                    content: "Đã gửi giải trình thành công!",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                );
              } catch (e, st) {
                debugPrint('Error showing dialog: $e\n$st');
              }
              try {
                _reasonController.clear();
              } catch (e, st) {
                debugPrint('Error clearing controller: $e\n$st');
              }
              Future.microtask(() {
                try {
                  _cubit.resetSubmitSuccess();
                } catch (e, st) {
                  debugPrint('Error resetting submitSuccess: $e\n$st');
                }
              });
            });
          }
        } catch (e, st) {
          debugPrint('Listener caught error: $e\n$st');
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final name = state.profile?.name ?? "Không xác định";

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField("Nhân viên", name),
              const SizedBox(height: 10),
              _buildReadOnlyField(
                "Phòng ban",
                state.profile?.department?.name ?? "Không xác định",
              ),
              const SizedBox(height: 10),
              _buildReadOnlyField("Giờ đến", "08:30"),
              const SizedBox(height: 10),
              _buildReadOnlyField("Giờ về", "18:00"),
              const SizedBox(height: 10),
              InputTextField(
                title: "Lý do",
                hintText: "Nhập lý do",
                controller: _reasonController,
                isRequiredField: true,
                maxLine: 3,
                enable: true,
                onChange: (value) {
                  _cubit.updateReason(value.trim());
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                mainText: "Xác nhận",
                enable: _isReasonFilled,
                callback: () {
                  if (_isReasonFilled) {
                    _cubit.sendInvalidReason();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
