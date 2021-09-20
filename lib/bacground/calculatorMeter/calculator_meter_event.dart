part of 'calculator_meter_bloc.dart';

@immutable
abstract class CalculatorMeterEvent {}

class InitialCalculatorMeter extends CalculatorMeterEvent {
  final List<DataModel> data;
  final LatLng location;
  final double zoom;
  InitialCalculatorMeter(
      {required this.data, required this.location, required this.zoom});
}

class SetMeterEvent extends CalculatorMeterEvent {
  final double zoom;
  final List<DataModel> data;
  final LatLng location;
  SetMeterEvent({
    required this.zoom,
    required this.data,
    required this.location,
  });
}
