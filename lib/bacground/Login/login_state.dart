part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginUserState extends LoginState{}
class LoginCenterState extends LoginState{
  final List<DataModel>? marker;

  LoginCenterState(this.marker);
}
class LoginNullState extends LoginState{}