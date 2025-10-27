part of 'app_cubit.dart';

class AppState extends Equatable {
  final TokenEntity? token;
  final LoadStatus? signOutStatus;
  final Locale? locale;

  AppState({
    this.token,
    this.signOutStatus,
    this.locale,
  });

  AppState copyWith({
    TokenEntity? token,
    LoadStatus? signOutStatus,
    bool? isShownAlertLogOut,
    Locale? locale,
  }) {
    return AppState(
      token: token ?? this.token,
      signOutStatus: signOutStatus ?? this.signOutStatus,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [
    token,
    signOutStatus,
    locale,
  ];
}