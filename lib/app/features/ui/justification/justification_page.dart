import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/features/ui/justification/create_justification_page.dart';
import 'package:pm_app/app/features/ui/justification/justification_detail.dart';
import 'package:pm_app/app/features/ui/justification/widgets/justification_list_item.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';

import 'bloc/justification_cubit.dart';

class JustificationPage extends StatefulWidget {
  final bool? isFromHome;
  const JustificationPage({super.key, this.isFromHome});

  @override
  State<JustificationPage> createState() => _JustificationPageState();
}

class _JustificationPageState extends State<JustificationPage> {
  final _cubit = JustificationCubit();
  final TextEditingController _filterCtrl = TextEditingController();
  final _df = DateFormat('dd/MM/yyyy');
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
  }

  void _showDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JustificationDetailPage()),
    );
  }

  Future<void> _openCalendar() async {
    final now = DateTime.now();
    final defaultRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );

    final res = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (_) => CalendarRangeSheet(
            initial: _selectedRange ?? defaultRange,
            locale: "vi",
          ),
    );

    if (res == null) {
      setState(() {
        _selectedRange = null;
        _filterCtrl.clear();
      });
      return;
    }

    setState(() {
      _selectedRange = res;
      _filterCtrl.text = "${_df.format(res.start)} - ${_df.format(res.end)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: MyAppBar(
          titleAppbar: "Đăng ký đi muộn về sớm",
          haveBackButton: widget.isFromHome ?? false,
          haveActionButton: true,
          iconPathAsset: AppAssets.icNotificationBell,
          actionCallBack: () {},
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openCalendar,
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _filterCtrl,
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateJustificationPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<JustificationCubit, JustificationState>(
                builder: (context, state) {
                  if ((state.listJustifications ?? []).isEmpty) {
                    return const Center(child: Text("CHƯA CÓ GÌ CẢ!!!"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    itemCount: state.listJustifications!.length,
                    itemBuilder: (context, index) {
                      final JustificationEntity item =
                          state.listJustifications![index];
                      return JustificationListItem(
                        entity: item,
                        onTap: () {
                          _showDetail();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
