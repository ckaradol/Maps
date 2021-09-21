part of 'calculator_meter_network_bloc.dart';

@immutable
abstract class CalculatorMeterNetworkEvent {}

class InitialEvent extends CalculatorMeterNetworkEvent {}

class SetEvent extends CalculatorMeterNetworkEvent {
  final List<DataModel> data;

  SetEvent(this.data);
}
