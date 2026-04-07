part of 'login_cubit.dart';

const Object _loginCopyWithUnset = Object();

class LoginState extends Equatable {
  final TokenEntity? tokenEntity;
  final LoadStatus? loginStatus;
  final bool? showPassword;
  final String? userName;
  final String password;
  final String? errMsg;
  final bool? rememberMe;

  const LoginState({
    this.tokenEntity,
    this.loginStatus = LoadStatus.INITIAL,
    this.showPassword,
    this.userName,
    this.password = "",
    this.errMsg,
    this.rememberMe
  });

  LoginState copyWith({
    TokenEntity? tokenEntity,
    LoadStatus? loginStatus,
    bool? showPassword,
    String? userName,
    String? email,
    String? password,
    String? teacherCode,
    Object? errMsg = _loginCopyWithUnset,
    bool? rememberMe
  }) {
    return LoginState(
        tokenEntity: tokenEntity ?? this.tokenEntity,
        loginStatus: loginStatus ?? this.loginStatus,
        showPassword: showPassword ?? this.showPassword,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        errMsg: identical(errMsg, _loginCopyWithUnset) ? this.errMsg : errMsg as String?,
        rememberMe: rememberMe ?? this.rememberMe
    );
  }
  @override
  List<Object?> get props => [
    tokenEntity,
    loginStatus,
    showPassword,
    userName,
    password,
    errMsg,
    rememberMe
  ];
}
