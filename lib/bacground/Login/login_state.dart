part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginUserState extends LoginState {}

class LoginCenterState extends LoginState {
  final List<DataModel>? marker;

  LoginCenterState(this.marker);
}

class LoginErrorState extends LoginState {
  final String error;

  LoginErrorState(this.error);
}

class LoginNullState extends LoginState {}
