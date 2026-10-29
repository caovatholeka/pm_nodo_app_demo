import 'package:flutter/widgets.dart';
import 'package:pm_app/app/data/models/entities/task_stage_entity.dart';
import 'package:pm_app/generated/l10n.dart';

/// Tên trạng thái việc (todo.task.stage) theo ngôn ngữ app. Tên lưu trên server chỉ có tiếng
/// Việt → tiếng Việt giữ đúng tên server trả về; ngôn ngữ khác dịch theo mã cố định
/// (new / in_progress / done / rejected), mã lạ thì hiện tên server.
String taskStageLabel(BuildContext context, TaskStageEntity? stage) {
  final serverName = stage?.name ?? '';
  if (Localizations.localeOf(context).languageCode == 'vi' && serverName.isNotEmpty) {
    return serverName;
  }
  final s = S.of(context);
  switch (stage?.code) {
    case 'new':
      return s.task_stage_new;
    case 'in_progress':
      return s.task_stage_in_progress;
    case 'done':
      return s.task_stage_done;
    case 'rejected':
      return s.task_stage_rejected;
    default:
      return serverName;
  }
}
