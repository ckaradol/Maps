part of 'calculator_meter_network_mark_bloc.dart';

@immutable
abstract class CalculatorMeterNetworkMarkEvent {}
class InitialMarkEvent extends CalculatorMeterNetworkMarkEvent {}

class SetMarkEvent extends CalculatorMeterNetworkMarkEvent {
  final List<DataModel> data;

  SetMarkEvent(this.data);
}