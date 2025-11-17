part of 'login_cubit.dart';

class LoginState extends Equatable {
  TokenEntity? tokenEntity;
  LoadStatus? loginStatus;
  bool? showPassword;
  String? userName;
  String password;
  String? errMsg;
  bool? rememberMe;

  LoginState({
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
    String? errMsg,
    bool? rememberMe
  }) {
    return LoginState(
        tokenEntity: tokenEntity ?? this.tokenEntity,
        loginStatus: loginStatus ?? this.loginStatus,
        showPassword: showPassword ?? this.showPassword,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        errMsg: errMsg ?? this.errMsg,
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