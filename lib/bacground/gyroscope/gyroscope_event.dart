part of 'gyroscope_bloc.dart';

@immutable
abstract class GyroscopeEvent {}
class GyroscopeInitialEvent extends GyroscopeEvent{

}
class GyroscopeSetStateEvent extends GyroscopeEvent{
 final  double event;

  GyroscopeSetStateEvent({required this.event});
}
class GyroscopeErrorEvent extends GyroscopeEvent{
final String gyroscopeError;

  GyroscopeErrorEvent({required this.gyroscopeError});
}