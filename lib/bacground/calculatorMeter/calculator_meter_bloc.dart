import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';

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
      List<DataModel> data = [];
      for (var model in event.data) {
        LatLng user = LatLng(model.lat!, model.lng!);
        Distance distance = Distance();
        double meter = distance.as(LengthUnit.Meter, user,
            event.location); //latlng 1 and latlng2 calculate meters between
        if (meter <= 150) {
          data.add(model);
        }
      }
      yield SetMeter(meter: 150, data: data, zoom: 17);
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
          } else if (event.zoom > 10 && event.zoom < 14) {
            meter = maxMeter / (event.zoom * event.zoom * event.zoom * 3);
          } else if (event.zoom > 14) {
            meter =
                maxMeter / (event.zoom * event.zoom * event.zoom * event.zoom);
          } else {
            meter = maxMeter / (event.zoom * event.zoom);
          }

          List<DataModel> data = [];
          for (var model in event.data) {
            LatLng user = LatLng(model.lat!, model.lng!);
            Distance distance = Distance();
            double userMeter = distance.as(LengthUnit.Meter, user,
                event.location); //latlng 1 and latlng2 calculate meters between
            if (userMeter <= meter) {
              data.add(model);
            }
          }
          print(calculatorMeterState.zoom);
          yield SetMeter(meter: meter, data: data, zoom: event.zoom);
        } else if (calculatorMeterState.zoom < event.zoom) {
          if (event.zoom > 5 && event.zoom < 7) {
            meter = maxMeter / (event.zoom * event.zoom * 2);
          } else if (event.zoom > 7 && event.zoom < 8) {
            meter = maxMeter / (event.zoom * event.zoom * 5);
          } else if (event.zoom > 8 && event.zoom < 10) {
            meter = maxMeter / (event.zoom * event.zoom * 7);
          } else if (event.zoom > 10 && event.zoom < 14) {
            meter = maxMeter / (event.zoom * event.zoom * event.zoom * 3);
          } else if (event.zoom > 14) {
            meter =
                maxMeter / (event.zoom * event.zoom * event.zoom * event.zoom);
          } else {
            meter = maxMeter / (event.zoom * event.zoom);
          }

          List<DataModel> data = [];
          for (var model in event.data) {
            LatLng user = LatLng(model.lat!, model.lng!);
            Distance distance = Distance();
            double userMeter = distance.as(LengthUnit.Meter, user,
                event.location); //latlng 1 and latlng2 calculate meters between
            if (userMeter <= meter) {
              data.add(model);
            }
          }
          print(meter);
          yield SetMeter(meter: meter, data: data, zoom: event.zoom);
        }
      }
    }
  }
}
