import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';

part 'calculator_meter_event.dart';

part 'calculator_meter_state.dart';

const double maxMeter = 10000000;
const double minMeter = 150;

class CalculatorMeterBloc
    extends Bloc<CalculatorMeterEvent, CalculatorMeterState> {
  CalculatorMeterBloc() : super(CalculatorMeterInitial());

  @override
  Stream<CalculatorMeterState> mapEventToState(
    CalculatorMeterEvent event,
  ) async* {
    if (event is InitialCalculatorMeter) {
      yield SetMeter(meter: 150, zoom: 17);
    }
    if (event is SetMeterEvent) {
      CalculatorMeterState calculatorMeterState = state;
      if (calculatorMeterState is SetMeter) {
        double meter = calculatorMeterState.meter;
        if (calculatorMeterState.zoom > event.zoom) {
          if (event.zoom > 5 && event.zoom < 7) {
            meter = maxMeter / (event.zoom * event.zoom * 2);
          } else if (event.zoom > 7 && event.zoom < 8) {
            meter = maxMeter / (event.zoom * event.zoom * 5);
          } else if (event.zoom > 8 && event.zoom < 10) {
            meter = maxMeter / (event.zoom * event.zoom * 7);
          } else if (event.zoom > 10 && event.zoom < 12) {
            meter = maxMeter / (event.zoom * event.zoom * 10);
          } else if (event.zoom > 12 && event.zoom < 14) {
            meter = maxMeter / (event.zoom * event.zoom * event.zoom * 3);
          } else if (event.zoom > 14) {
            meter =
                maxMeter / (event.zoom * event.zoom * event.zoom * event.zoom);
          } else {
            meter = maxMeter / (event.zoom * event.zoom);
          }
          yield SetMeter(meter: meter, zoom: event.zoom);
        } else if (calculatorMeterState.zoom < event.zoom) {
          if (event.zoom > 5 && event.zoom < 7) {
            meter = maxMeter / (event.zoom * event.zoom * 2);
          } else if (event.zoom > 7 && event.zoom < 8) {
            meter = maxMeter / (event.zoom * event.zoom * 5);
          } else if (event.zoom > 8 && event.zoom < 10) {
            meter = maxMeter / (event.zoom * event.zoom * 7);
          } else if (event.zoom > 10 && event.zoom < 12) {
            meter = maxMeter / (event.zoom * event.zoom * 10);
          } else if (event.zoom > 12 && event.zoom < 14) {
            meter = maxMeter / (event.zoom * event.zoom * event.zoom * 3);
          } else if (event.zoom > 14) {
            meter =
                maxMeter / (event.zoom * event.zoom * event.zoom * event.zoom);
          } else {
            meter = maxMeter / (event.zoom * event.zoom);
          }

          yield SetMeter(meter: meter, zoom: event.zoom);
        }
      }
    }
  }
}
