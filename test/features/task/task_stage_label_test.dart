import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/app/core/utils/task_stage_label.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Dựng 1 Text hiện nhãn các trạng thái theo [locale], trả về danh sách nhãn.
Future<List<String>> _labels(WidgetTester tester, Locale locale, List<TaskStageEntity?> stages) async {
  late List<String> out;
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    locale: locale,
    home: Builder(builder: (context) {
      out = stages.map((e) => taskStageLabel(context, e)).toList();
      return const SizedBox();
    }),
  ));
  await tester.pump();
  return out;
}

final _stages = [
  TaskStageEntity(id: 1, code: 'new', name: 'Mới'),
  TaskStageEntity(id: 2, code: 'in_progress', name: 'Đang thực hiện'),
  TaskStageEntity(id: 3, code: 'done', name: 'Hoàn thành'),
  TaskStageEntity(id: 4, code: 'rejected', name: 'Từ chối'),
  TaskStageEntity(id: 9, code: 'review', name: 'Chờ review'),
];

void main() {
  testWidgets('tiếng Việt: giữ đúng tên server trả về', (tester) async {
    expect(await _labels(tester, const Locale('vi'), _stages),
        ['Mới', 'Đang thực hiện', 'Hoàn thành', 'Từ chối', 'Chờ review']);
  });

  testWidgets('tiếng Anh: dịch theo mã, mã lạ hiện tên server', (tester) async {
    expect(await _labels(tester, const Locale('en'), _stages),
        ['New', 'In Progress', 'Completed', 'Rejected', 'Chờ review']);
  });

  testWidgets('không có trạng thái → chuỗi rỗng', (tester) async {
    expect(await _labels(tester, const Locale('en'), [null]), ['']);
  });
}
