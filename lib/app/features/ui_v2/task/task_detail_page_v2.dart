import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/theme_v2/app_tokens_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/ambient_background_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/glass_card_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/primary_button_v2.dart';
import 'package:pm_app/app/core/theme_v2/widgets/stagger_reveal_v2.dart';
import 'package:pm_app/app/core/utils/date_utils.dart';
import 'package:pm_app/app/data/models/entities/task_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/features/ui/notification/noti_cubit.dart';
import 'package:pm_app/app/features/ui/notification/noti_page.dart';
import 'package:pm_app/app/features/ui/task/bloc/task_cubit.dart';
import 'package:pm_app/app/features/ui_v2/task/create_new_task_v2.dart';
import 'package:pm_app/app/features/widgets/app_snackbar.dart';
import 'package:pm_app/app/features/widgets/custom_dialog.dart';
import 'package:pm_app/app/features/widgets/loading_overlay.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:pm_app/app/core/theme_v2/widgets/bottom_sheet_bar_theme_v2.dart';

/// Màn Chi tiết công việc — phiên bản giao diện tối (v2).
///
/// Hành vi/nghiệp vụ giữ NGUYÊN bản cũ [TaskDetailPage]: cùng [TaskCubit]
/// (qua GetIt), cùng gọi `getDetailTask` ở initState, cùng xử lý
/// deleteStatus (loading/thành công -> pop(true)/thất bại), cùng dialog xác
/// nhận xoá, cùng luật chỉ hiện thanh Xoá/Sửa khi người đăng nhập là người
/// giao việc (assigner), cùng điều hướng sang màn Sửa
/// ([CreateNewTaskV2], isEdit: true) rồi pop(true) khi cập nhật thành công.
///
/// Ghi chú: field `priority` trên [TaskEntity] là `String?` nên phép so
/// sánh gốc `priority == 1` luôn sai (không bao giờ tô vàng sao ưu tiên) —
/// đây là hành vi có sẵn của bản cũ, được giữ nguyên y hệt ở đây theo đúng
/// quy tắc "fidelity over styling".
class TaskDetailPageV2 extends StatefulWidget {
  int? taskId;
  TaskEntity? taskEntity;

  TaskDetailPageV2({super.key, this.taskId, this.taskEntity});

  @override
  State<TaskDetailPageV2> createState() => _TaskDetailPageV2State();
}

class _TaskDetailPageV2State extends State<TaskDetailPageV2> {
  final _cubit = GetIt.I.get<TaskCubit>();

  @override
  void initState() {
    _cubit.getDetailTask(widget.taskId ?? 0);
    super.initState();
  }

  void _goNotification() {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.I<NotiCubit>()..loadNotifications("all"),
          child: const NotificationPage(),
        ),
      ),
    );
  }

  Color _getStatusColor(String code) {
    switch (code) {
      case "new":
        return AppTokensV2.accent2;
      case "in_progress":
        return AppTokensV2.accent;
      case "done":
        return AppTokensV2.success;
      case "rejected":
        return AppTokensV2.danger;
      default:
        return AppTokensV2.fgMuted;
    }
  }

  // Bỏ nền sáng mặc định của khung nút ở đáy (Scaffold.bottomSheet) → chỉ còn nút.
  @override
  Widget build(BuildContext context) =>
      BottomSheetBarThemeV2(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<TaskCubit, TaskState>(
      bloc: _cubit,
      // Chỉ nghe trạng thái xóa: trước đây nghe mọi thay đổi nên nhánh `else` cuối ẩn cả
      // loading của màn Sửa việc mở phía trên, và ẩn ngay loading vừa hiện khi bấm Xóa.
      listenWhen: (prev, cur) => prev.deleteStatus != cur.deleteStatus,
      listener: (context, state) {
        if (state.deleteStatus == LoadStatus.LOADING) {
          LoadingOverlay.show(context);
        } else if (state.deleteStatus == LoadStatus.SUCCESS) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showInfo(
            title: s.success,
            message: s.todo_delete_success,
          );
          Navigator.pop(context, true);
        } else if (state.deleteStatus == LoadStatus.FAILURE) {
          _cubit.resetStatus();
          LoadingOverlay.hide(context);
          AppSnackBar.showError(title: s.warning, message: s.to_do_failed);
        } else {
          LoadingOverlay.hide(context);
        }
      },
      builder: (context, state) {
        final isAssigner = (state.detailTask?.assigner?.id ?? 0) ==
            GlobalData.instance.userProfile?.id;

        return Scaffold(
          backgroundColor: AppTokensV2.bgDeep,
          body: AmbientBackgroundV2(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: StaggerRevealV2(index: 0, child: _topBar(s)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BlocBuilder<TaskCubit, TaskState>(
                      bloc: _cubit,
                      buildWhen: (prev, cur) =>
                          prev.loadDetailStatus != cur.loadDetailStatus ||
                          prev.detailTask != cur.detailTask,
                      builder: (context, state) {
                        if (state.loadDetailStatus == LoadStatus.LOADING) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppTokensV2.accent,
                              strokeWidth: 2.2,
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            isAssigner ? 100 : 24,
                          ),
                          child: StaggerRevealV2(
                            index: 1,
                            child: _detailCard(s, state),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: isAssigner ? _bottomBar(s) : null,
        );
      },
    );
  }

  Widget _topBar(S s) {
    return Row(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTokensV2.fg, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          s.to_do_detail_title,
          style: AppTokensV2.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNotification,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTokensV2.surfaceStrong,
            border: Border.all(color: AppTokensV2.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.notifications_none_rounded,
              size: 20, color: AppTokensV2.fgSoft),
        ),
      ),
    ]);
  }

  Widget _detailCard(S s, TaskState state) {
    final task = state.detailTask;
    final isPriority = task?.priority == 1;
    final statusColor = _getStatusColor(task?.stage?.code ?? "");

    return GlassCardV2(
      radius: AppTokensV2.radius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task?.name ?? "",
                  style: AppTokensV2.title.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isPriority ? Icons.star_rounded : Icons.star_border_rounded,
                size: 24,
                color: isPriority ? AppTokensV2.warn : AppTokensV2.fgMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _divider(),
          const SizedBox(height: 12),
          _infoRow(
            s.to_jobtype,
            (task?.taskType ?? "") == "normal"
                ? s.todo_detail_status1
                : s.todo_detail_status2,
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          _infoRow(s.to_do_card_taskmaster, task?.assigner?.name ?? ""),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          _infoRow(
            s.to_taskempl,
            task?.userIds?.map((sc) => sc.name).toList().join(",") ?? "",
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          _infoRow(
            s.to_do_card_deadline,
            AppDateUtils.changeIso8601StringToDateTimeString(
              task?.deadline ?? "",
            ),
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.day_off_card_status, style: AppTokensV2.caption),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (task?.stage?.name ?? "").toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _divider(),
          const SizedBox(height: 12),
          Text(s.to_description, style: AppTokensV2.caption),
          const SizedBox(height: 6),
          Text(
            task?.description ?? "",
            style: AppTokensV2.body,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppTokensV2.border);

  Widget _infoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 4,
          child: Text(title, style: AppTokensV2.caption, maxLines: 2),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: AppTokensV2.body,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(S s) {
    return Container(
      margin: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).padding.bottom + 18,
      ),
      child: Row(
        children: [
          Expanded(
            child: _dangerButton(
              label: s.day_off_btn_delete,
              onTap: showDeleteConfirmDialog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButtonV2(
              label: s.day_off_btn_edit,
              onTap: () => doUpdate(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangerButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTokensV2.danger.withValues(alpha: 0.14),
          border: Border.all(color: AppTokensV2.danger.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTokensV2.danger,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Helper func
  Future<void> doUpdate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewTaskV2(
          isEdit: true,
          detailEntity: _cubit.state.detailTask,
        ),
      ),
    );
    if (updated == true) {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  void showDeleteConfirmDialog() {
    final s = S.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CustomDialog(
        iconPath: AppAssets.ic_delete,
        title: s.todo_confirm_delete,
        content: "${s.todo_subtitle1} \n"
            "${s.todo_subtitle2}",
        success: false,
        confirmText: s.day_off_btn_delete,
        cancelText: s.cancel,
        onConfirm: () {
          Navigator.pop(context);
          _cubit.deleteTask(_cubit.state.detailTask?.id ?? 0);
        },
      ),
    );
  }
}
