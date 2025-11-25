import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/notification_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/user_repository.dart';

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
    emit(state.copyWith(status: LoadStatus.LOADING, currentPage: 1));

    final params = _buildNotiParams(type, page: 1);
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
    } else {
      emit(state.copyWith(status: LoadStatus.FAILURE));
    }
  }

  Future<void> loadMore(String type) async {
    if (!state.canLoadMore || state.status == LoadStatus.LOADING_MORE) return;

    emit(state.copyWith(status: LoadStatus.LOADING_MORE));

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
  }

  Future<void> markRead({required bool markAll, int? id}) async {
    try {
      final body = {"mark_all": markAll ? "True" : "False", "noti_id": id ?? 0};
    } catch (e, s) {
      logger.e("markRead error: $e");
      logger.d("where: $s");
    }
  }
}
