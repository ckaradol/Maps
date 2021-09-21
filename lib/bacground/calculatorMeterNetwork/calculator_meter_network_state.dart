part of 'calculator_meter_network_bloc.dart';

@immutable
abstract class CalculatorMeterNetworkState {}

class CalculatorMeterNetworkInitial extends CalculatorMeterNetworkState {}

class CalculatorMeterNetworkListen extends CalculatorMeterNetworkState {
  final List<DataModel> data;

  CalculatorMeterNetworkListen(this.data);
}
