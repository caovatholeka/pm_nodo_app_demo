part of 'login_cubit.dart';

class LoginState extends Equatable {
  TokenEntity? tokenEntity;
  LoadStatus? loginStatus;
  bool? showPassword;
  String? userName;
  String password;
  String? errMsg;

  LoginState({
    this.tokenEntity,
    this.loginStatus = LoadStatus.INITIAL,
    this.showPassword,
    this.userName,
    this.password = "",
    this.errMsg
  });

  LoginState copyWith({
    TokenEntity? tokenEntity,
    LoadStatus? loginStatus,
    bool? showPassword,
    String? userName,
    String? email,
    String? password,
    String? teacherCode,
    String? errMsg
  }) {
    return LoginState(
        tokenEntity: tokenEntity ?? this.tokenEntity,
        loginStatus: loginStatus ?? this.loginStatus,
        showPassword: showPassword ?? this.showPassword,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        errMsg: errMsg ?? this.errMsg
    );
  }
  @override
  List<Object?> get props => [
    tokenEntity,
    loginStatus,
    showPassword,
    userName,
    password,
    errMsg
  ];
}