import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';
import 'package:pm_app/app/features/bloc/app_cubit.dart';

part 'noti_state.dart';

class NotiCubit extends Cubit<NotiState> {
  final UserRepository userRepository;

  NotiCubit({required this.userRepository}) : super(const NotiState());

  Map<String, dynamic> _buildNotiParams(
    String type, {
    int page = 1,
    int limit = 20,
  }) {
    return {"type": type, "page": page, "limit": limit};
  }


  Future<void> loadNotifications(String type) async {
    emit(
      state.copyWith(
        status: LoadStatus.LOADING,
        currentPage: 1,
        canLoadMore: true,
      ),
    );

    try {
      final params = _buildNotiParams(type);
      final res = await userRepository.getNotification(params);

      if (res.code == 200) {
        final list =
            (res.data as List)
                .map((e) => NotificationEntity.fromJson(e))
                .toList();

        emit(
          state.copyWith(
            status: LoadStatus.SUCCESS,
            notifications: list,
            totalUnread: res.totalUnread ?? 0,
            canLoadMore: list.length >= params["limit"],
          ),
        );
        _syncGlobalUnreadCount(res.totalUnread ?? 0);
      } else {
        emit(state.copyWith(status: LoadStatus.FAILURE));
      }
    } catch (e, s) {
      logger.e("loadNotifications error: $e");
      logger.d("stack: $s");
      emit(state.copyWith(status: LoadStatus.FAILURE));
    }
  }

  Future<void> loadMore(String type) async {
    if (!state.canLoadMore || state.status == LoadStatus.LOADING_MORE) return;

    emit(state.copyWith(status: LoadStatus.LOADING_MORE));

    try {
      final nextPage = state.currentPage + 1;
      final params = _buildNotiParams(type, page: nextPage);

      final res = await userRepository.getNotification(params);

      if (res.code == 200) {
        final addList =
            (res.data as List)
                .map((e) => NotificationEntity.fromJson(e))
                .toList();

        emit(
          state.copyWith(
            status: LoadStatus.SUCCESS,
            notifications: [...state.notifications, ...addList],
            currentPage: nextPage,
            canLoadMore: addList.length >= params["limit"],
          ),
        );
      } else {
        emit(state.copyWith(status: LoadStatus.FAILURE));
      }
    } catch (e, s) {
      logger.e("loadMore error: $e");
      logger.d("stack: $s");
      emit(state.copyWith(status: LoadStatus.FAILURE));
    }
  }

  Future<void> markRead({required bool markAll, int? id}) async {
    if (markAll) {
      final updatedList =
          state.notifications.map((e) => e.copyWith(isSeen: true)).toList();

      emit(
        state.copyWith(
          notifications: updatedList,
          totalUnread: 0,
        ),
      );
      _syncGlobalUnreadCount(0);
    } else if (id != null) {
      final updatedList = state.notifications.map((e) {
        if (e.id == id && !(e.isSeen ?? false)) {
          return e.copyWith(isSeen: true);
        }
        return e;
      }).toList();

      final nextUnread = state.totalUnread > 0 ? state.totalUnread - 1 : 0;

      emit(
        state.copyWith(
          notifications: updatedList,
          totalUnread: nextUnread,
        ),
      );
      _syncGlobalUnreadCount(nextUnread);
    }

    try {
      final body = {"mark_all": markAll ? "True" : "False"};

      await userRepository.markNotiRead(
        body,
        markAll ? 0 : (id ?? 0),
      );

      await countUnreadNoti();
    } catch (e, s) {
      logger.e('markRead error: $e');
      logger.d('stack: $s');
      await countUnreadNoti();
    }
  }

  Future<void> countUnreadNoti() async {
    try {
      final res = await userRepository.countUnreadNoti();

      if (res.code == 200) {
        final data = res.data as Map<String, dynamic>;
        final unread = (data['unread_count'] as num?)?.toInt() ?? 0;

        emit(state.copyWith(totalUnread: unread));
        _syncGlobalUnreadCount(unread);
      }
    } catch (e, s) {
      logger.e("countUnreadNoti error: $e");
      logger.d("stack: $s");
    }
  }

  void _syncGlobalUnreadCount(int unread) {
    try {
      if (GetIt.I.isRegistered<AppCubit>()) {
        GetIt.I<AppCubit>().syncUnreadCount(unread);
      }
    } catch (e, s) {
      logger.e("sync global unread error: $e");
      logger.d("stack: $s");
    }
  }



  
}
