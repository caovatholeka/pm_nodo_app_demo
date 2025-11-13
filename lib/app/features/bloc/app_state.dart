part of 'app_cubit.dart';

class AppState extends Equatable {
  final TokenEntity? token;
  final LoadStatus? signOutStatus;
  final Locale? locale;
  ProfileEntity? userProfile;
  List<WorkEntryTypeEntity>? listWorkEntryTypes;
  List<WorkFlowStageEntity>? listWorkFlowStages;

  AppState({
    this.token,
    this.signOutStatus,
    this.locale,
    this.userProfile,
    this.listWorkEntryTypes,
    this.listWorkFlowStages
  });

  factory AppState.initial() => AppState(locale: Locale('vi'));

  AppState copyWith({
    TokenEntity? token,
    LoadStatus? signOutStatus,
    bool? isShownAlertLogOut,
    Locale? locale,
    ProfileEntity? userProfile,
    List<WorkEntryTypeEntity>? listWorkEntryTypes,
    List<WorkFlowStageEntity>? listWorkFlowStages
  }) {
    return AppState(
      token: token ?? this.token,
      signOutStatus: signOutStatus ?? this.signOutStatus,
      locale: locale ?? this.locale,
      userProfile: userProfile ?? this.userProfile,
      listWorkEntryTypes: listWorkEntryTypes ?? this.listWorkEntryTypes,
      listWorkFlowStages: listWorkFlowStages ?? this.listWorkFlowStages
    );
  }

  @override
  List<Object?> get props => [
    token,
    signOutStatus,
    locale,
    userProfile,
    listWorkEntryTypes,
    listWorkFlowStages
  ];
}