part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginCenterEvent extends LoginEvent {}

class LoginUserEvent extends LoginEvent {}

class LoginOnlineEvent extends LoginEvent {}

class LoginOfflineEvent extends LoginEvent {}

class LoginErrorEvent extends LoginEvent {
  final String error;

  LoginErrorEvent(this.error);
}

class LoginNullEvent extends LoginEvent {}

class LoginSetStateEvent extends LoginEvent {
  final bool center;
  final List<DataModel>? marker;
  LoginSetStateEvent({required this.center, required this.marker});
}
