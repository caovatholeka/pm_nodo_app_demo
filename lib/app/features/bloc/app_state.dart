part of 'app_cubit.dart';

class AppState extends Equatable {
  final TokenEntity? token;
  final LoadStatus? signOutStatus;
  final Locale? locale;
  final int? totalUnread;
  final bool isLoggedIn;
  final bool tokenExpired;
  ProfileEntity? userProfile;
  List<WorkEntryTypeEntity>? listWorkEntryTypes;
  List<WorkFlowStageEntity>? listWorkFlowStages;

  // trạng thái task
  final List<TaskStageEntity>? listTaskStages;

  AppState({
    this.token,
    this.signOutStatus,
    this.locale,
    this.userProfile,
    this.listWorkEntryTypes,
    this.listWorkFlowStages,
    this.listTaskStages,
    this.totalUnread = 0,
    this.isLoggedIn = true,
    this.tokenExpired = false,
  });

  factory AppState.initial() => AppState(locale: Locale('vi'));

  AppState copyWith({
    TokenEntity? token,
    LoadStatus? signOutStatus,
    bool? isShownAlertLogOut,
    Locale? locale,
    ProfileEntity? userProfile,
    List<WorkEntryTypeEntity>? listWorkEntryTypes,
    List<WorkFlowStageEntity>? listWorkFlowStages,
    List<TaskStageEntity>? listTaskStages,
    int? totalUnread,
    bool? isLoggedIn,
    bool? tokenExpired,
  }) {
    return AppState(
      token: token ?? this.token,
      signOutStatus: signOutStatus ?? this.signOutStatus,
      locale: locale ?? this.locale,
      userProfile: userProfile ?? this.userProfile,
      listWorkEntryTypes: listWorkEntryTypes ?? this.listWorkEntryTypes,
      listWorkFlowStages: listWorkFlowStages ?? this.listWorkFlowStages,
      listTaskStages: listTaskStages ?? this.listTaskStages,
      totalUnread: totalUnread ?? this.totalUnread,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      tokenExpired: tokenExpired ?? this.tokenExpired,
    );
  }

  @override
  List<Object?> get props => [
    token,
    signOutStatus,
    locale,
    userProfile,
    listWorkEntryTypes,
    listWorkFlowStages,
    listTaskStages,
    totalUnread,
    isLoggedIn,
    tokenExpired,
  ];
}