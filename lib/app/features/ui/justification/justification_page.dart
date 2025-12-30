import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/justification/create_justification_page.dart';
import 'package:pm_app/app/features/ui/justification/justification_detail.dart';
import 'package:pm_app/app/features/ui/justification/widgets/justification_list_item.dart';
import 'package:pm_app/app/features/widgets/custom_calendar_range_sheet.dart';
import 'package:pm_app/app/features/widgets/my_app_bar.dart';
import 'package:pm_app/generated/l10n.dart';

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
    _cubit.loadList();
  }

  @override
  void dispose() {
    _filterCtrl.dispose();
    _cubit.close();
    super.dispose();
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
      builder: (_) => CalendarRangeSheet(
        initial: _selectedRange ?? defaultRange,
        locale: "vi",
      ),
    );

    if (res == null) {
      setState(() {
        _selectedRange = null;
        _filterCtrl.clear();
      });

      _cubit.loadList();
      return;
    }

    setState(() {
      _selectedRange = res;
      _filterCtrl.text =
          "${_df.format(res.start)} - ${_df.format(res.end)}";
    });

    _cubit.loadList(
      startDate: DateFormat('yyyy-MM-dd').format(res.start),
      endDate: DateFormat('yyyy-MM-dd').format(res.end),
    );
  }

  void _refreshList() {
    if (_selectedRange != null) {
      _cubit.loadList(
        startDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.start),
        endDate: DateFormat('yyyy-MM-dd').format(_selectedRange!.end),
      );
    } else {
      _cubit.loadList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: MyAppBar(
          titleAppbar: s.justification_title,
          haveBackButton: widget.isFromHome ?? false,
          haveActionButton: true,
          iconPathAsset: AppAssets.icNotificationBell,
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateJustificationPage(),
                        ),
                      );
                      _refreshList();
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
                  if (state.loadStatus == LoadStatus.LOADING) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }

                  if (state.loadStatus == LoadStatus.FAILURE) {
                    return Center(
                      child: Text(state.error ?? 'Có lỗi xảy ra'),
                    );
                  }

                  if (state.list.isEmpty) {
                    return Center(
                      child: Text(S.of(context).justification_emptyData),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      final item = state.list[index];
                      return JustificationListItem(
                        entity: item,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JustificationDetailPage(id: item.id),
                            ),
                          );
                          _refreshList();
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