part of 'calculator_meter_bloc.dart';

@immutable
abstract class CalculatorMeterState {}

class CalculatorMeterInitial extends CalculatorMeterState {}

class SetMeter extends CalculatorMeterState {
  final double zoom;
  final double meter;

  SetMeter({required this.meter, required this.zoom});
}
