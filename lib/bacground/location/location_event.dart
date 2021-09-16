part of 'location_bloc.dart';

@immutable
abstract class LocationEvent {}
class LocationInitialEvent extends LocationEvent{}
class LocationSetStateEvent extends LocationEvent{
  final LocationData data;

  LocationSetStateEvent({required this.data});
}