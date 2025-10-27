part of 'splash_cubit.dart';

enum LoginState { INITIAL, LOGGED_IN, LOGGED_OUT, ERROR }

class SplashState extends Equatable {
  final LoginState loginState;

  const SplashState({
    this.loginState = LoginState.INITIAL,
  });

  SplashState copyWith({
    LoginState? loginState,
  }) {
    return SplashState(
      loginState: loginState ?? this.loginState,
    );
  }

  @override
  List<Object?> get props => [
    loginState,
  ];
}