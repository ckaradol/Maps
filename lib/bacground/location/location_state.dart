part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}
class LocationSetState extends LocationState{
  final LocationData locationData;

  LocationSetState({required this.locationData});
}