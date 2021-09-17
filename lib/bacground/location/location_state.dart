part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}
class LocationSetState extends LocationState{
  final LatLng locationData;
  final double accuracy;
  final bool? isMock;

  LocationSetState( {required this.locationData,required this.accuracy,required this.isMock,  });
}