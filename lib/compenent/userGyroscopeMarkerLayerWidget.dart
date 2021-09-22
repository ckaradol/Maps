import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/gyroscope/gyroscope_bloc.dart';
import 'package:map/compenent/paintTriangle.dart';
import 'package:map/screen/ErrorPopUpScreen.dart';
import 'dart:math' as math;

class UserGyroscopeMarkerLayerWidget extends StatelessWidget {
  const UserGyroscopeMarkerLayerWidget({
    Key? key,
    required this.locationData,
  }) : super(key: key);

  final LatLng locationData;

  @override
  Widget build(BuildContext context) {
    return MarkerLayerWidget(
      options: MarkerLayerOptions(
        markers: [
          Marker(
              width: 80,
              height: 80,
              point: locationData,
              builder: (BuildContext context) {
                return BlocProvider(
                  create: (context) =>
                      GyroscopeBloc()..add(GyroscopeInitialEvent()),
                  child: BlocConsumer<GyroscopeBloc, GyroscopeState>(
                    listener: (context, state) {
                      if (state is GyroscopeErrorState) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Error!!!"),
                                  content: ErrorPopUpScreen(
                                    error: state.error,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Ok"))
                                  ],
                                ));
                      }
                    },
                    builder: (context, state) {
                      if (state is GyroscopeSetStateState)
                        return AnimatedRotation(
                          turns: (state.event * (math.pi / 180)) / (2 * pi),
                          curve: Curves.easeInOutCubic,
                          //angle*(math.pi / 180) convert degrees to radians Animation controlling the child's rotation. If the current value of the rotation animation is v, then v * 2 * pi radians will be rotated before the child is painted. Therefore(2*pi) divided
                          duration: Duration(milliseconds: 200),//animation duration
                          child: Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                width: 30,
                                height: 30,
                                child: CustomPaint(
                                  painter: PaintTriangle(),
                                  child: Container(),
                                ),
                              ),
                            ],
                          ),
                        );
                      else
                        return Container();
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}
