part of 'noti_cubit.dart';

class NotiState extends Equatable {
  final LoadStatus status;
  final List<NotificationEntity> notifications;
  final int totalUnread;
  final int currentPage;
  final bool canLoadMore;

  const NotiState({
    this.status = LoadStatus.INITIAL,
    this.notifications = const [],
    this.totalUnread = 0,
    this.currentPage = 1,
    this.canLoadMore = true,
  });

  NotiState copyWith({
    LoadStatus? status,
    List<NotificationEntity>? notifications,
    int? totalUnread,
    int? currentPage,
    bool? canLoadMore,
  }) {
    return NotiState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      totalUnread: totalUnread ?? this.totalUnread,
      currentPage: currentPage ?? this.currentPage,
      canLoadMore: canLoadMore ?? this.canLoadMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        totalUnread,
        currentPage,
        canLoadMore,
      ];
}
