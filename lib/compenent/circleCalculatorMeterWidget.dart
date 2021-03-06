import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map/bacground/calculatorMeter/calculator_meter_bloc.dart';
import 'package:map/bacground/calculatorMeterNetwork/calculator_meter_network_bloc.dart';
import 'package:latlong2/latlong.dart';

import 'buildDataMarkers.dart';

class CircleCalculatorMeterWidget extends StatelessWidget {
  const CircleCalculatorMeterWidget({
    Key? key,
    required this.locationData,
  }) : super(key: key);

  final LatLng locationData;

  @override
  Widget build(BuildContext context) {
    CalculatorMeterState calculatorMeterState =context.read<CalculatorMeterBloc>().state;
    if(calculatorMeterState is SetMeter) {
      return Stack(
        children: [
          CircleLayerWidget(
            options: CircleLayerOptions(
              circles: [
                CircleMarker(
                    point: locationData,
                    color: Colors.blue.shade50.withOpacity(0.7),
                    useRadiusInMeter: true,
                    radius: calculatorMeterState.meter),
              ],
            ),
          ),
        ],
      );
    }else{
      return Container();
    }
  }
}
