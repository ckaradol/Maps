part of 'calculator_meter_network_mark_bloc.dart';

@immutable
abstract class CalculatorMeterNetworkMarkState {}

class CalculatorMeterNetworkMarkInitial extends CalculatorMeterNetworkMarkState {}

class CalculatorMeterNetworkMarkListen extends CalculatorMeterNetworkMarkState {
  final List<DataModel> data;

  CalculatorMeterNetworkMarkListen(this.data);
}

