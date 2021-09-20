part of 'connectivity_bloc.dart';

@immutable
abstract class ConnectivityEvent {}

class ConnectivityInitialEvent extends ConnectivityEvent {}

class ConnectivityChecked extends ConnectivityEvent {
  final ConnectivityResult result;

  ConnectivityChecked(this.result);
}
