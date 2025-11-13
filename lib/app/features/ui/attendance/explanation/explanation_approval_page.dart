import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/attendance/explanation/explanation_list_cubit.dart';
import 'package:pm_app/app/features/ui/attendance/explanation/explanation_list_state.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/app/features/widgets/explanation_card.dart';

class WorkEntryPage extends StatefulWidget {
  const WorkEntryPage({super.key});

  @override
  State<WorkEntryPage> createState() => _WorkEntryPageState();
}

class _WorkEntryPageState extends State<WorkEntryPage> {
  final cubit = GetIt.I.get<WorkEntryCubit>();

  final String dateFrom = "2025-09-01";  
  final String dateTo   = "2025-09-30";

  @override
  void initState() {
    super.initState();
    cubit.loadWorkEntries(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  String _mapStatus(String? state) {
    switch (state) {
      case "validated":
        return "Hợp lệ";
      case "invalidated":
        return "Chưa xác nhận";
      case "draft":
        return "Nháp";
      default:
        return "Không rõ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.imgBg2),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          children: [
            SafeArea(
              child: MyAppBar(
                titleAppbar: "Danh sách chấm công",
                haveBackButton: true,
                haveActionButton: false,
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),

                child: BlocBuilder<WorkEntryCubit, WorkEntryState>(
                  bloc: cubit,
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Center(
                        child: Text(
                          "Lỗi: ${state.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state.list.isEmpty) {
                      return const Center(child: Text("Không có dữ liệu"));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: state.list.length,
                      itemBuilder: (context, index) {
                        final item = state.list[index];

                        return ExplanationItem(
                          title: item.workEntryLabel ?? "Không xác định",
                          department: item.shift?.name ?? "Không rõ",
                          time: item.date ?? "-",
                          status: _mapStatus(item.state),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
