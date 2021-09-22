part of 'gyroscope_bloc.dart';

@immutable
abstract class GyroscopeState {}

class GyroscopeInitial extends GyroscopeState {}
class GyroscopeSetStateState extends GyroscopeState{
 final double event;

  GyroscopeSetStateState({required this.event});
}
class GyroscopeErrorState extends GyroscopeState{
 final String error;

  GyroscopeErrorState({required this.error});
}
