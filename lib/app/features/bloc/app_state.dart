part of 'app_cubit.dart';

class AppState extends Equatable {
  final TokenEntity? token;
  final LoadStatus? signOutStatus;
  final Locale? locale;
  ProfileEntity? userProfile;

  AppState({
    this.token,
    this.signOutStatus,
    this.locale,
    this.userProfile
  });

  AppState copyWith({
    TokenEntity? token,
    LoadStatus? signOutStatus,
    bool? isShownAlertLogOut,
    Locale? locale,
    ProfileEntity? userProfile,
  }) {
    return AppState(
      token: token ?? this.token,
      signOutStatus: signOutStatus ?? this.signOutStatus,
      locale: locale ?? this.locale,
      userProfile: userProfile ?? this.userProfile
    );
  }

  @override
  List<Object?> get props => [
    token,
    signOutStatus,
    locale,
    userProfile
  ];
}