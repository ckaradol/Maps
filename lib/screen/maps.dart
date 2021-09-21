import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:map/bacground/calculatorMeter/calculator_meter_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/compenent/dataMarker.dart';
import 'package:map/compenent/userMarker.dart';
import 'package:map/compenent/zoombuttons_plugin_option.dart';

const double maxMetre = 30000;
const double minMetre = 300;

class Maps extends StatefulWidget {
  const Maps({
    Key? key,
  }) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> with TickerProviderStateMixin {
  final MapController mapController =
      MapController(); //MapController initialized
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  onWillPop() {
    LoginState loginState = context.read<LoginBloc>().state;
    if (loginState is LoginUserState) {
      FirebaseDatabase.instance.goOffline();
      FirebaseAuth.instance.signOut();
    }
    context.read<LoginBloc>().add(LoginNullEvent());
    return false;
  }

  bool online = true;

  double km = 300;

  Distance distance = Distance();

  @override
  void initState() {
    super.initState();
    LoginState loginState = context.read<LoginBloc>().state;
    LocationState locationState = context.read<LocationBloc>().state;
    if (loginState is LoginCenterState) {
      if (locationState is LocationSetState)
        mapController.mapEventStream.forEach((map) {
          context.read<CalculatorMeterBloc>().add(SetMeterEvent(
              location: locationState.locationData,
              data: loginState.marker!,
              zoom: map.zoom));
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    LoginState loginState = context.read<LoginBloc>().state;
    LocationState locationState = context.read<LocationBloc>().state;
    if (locationState is LocationSetState) {
      return WillPopScope(
        onWillPop: () {
          return onWillPop();
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    minZoom: 1,
                    maxZoom: 18,
                    center: locationState.locationData,
                    zoom: 17,
                    plugins: [
                      ZoomButtonsPlugin(),
                    ],
                  ),
                  nonRotatedLayers: [
                    ZoomButtonsPluginOption(
                      mini: true,
                      padding: 10,
                      alignment: Alignment.bottomLeft,
                    ),
                  ],
                  children: [
                    TileLayerWidget(
                      options: TileLayerOptions(
                        zoomReverse: false,
                        urlTemplate:
                            "https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425",
                        subdomains: ['a', 'b', 'c'],
                      ),
                    ),
                    if (loginState is LoginCenterState)
                      BlocBuilder<CalculatorMeterBloc, CalculatorMeterState>(
                        builder: (context, calculatorMeterState) {
                          if (calculatorMeterState is SetMeter)
                            return Stack(
                              children: [
                                MarkerLayerWidget(
                                  options: MarkerLayerOptions(
                                    markers: calculatorMeterState.data.map((e) {
                                      return Marker(
                                        width: 80,
                                        height: 80,
                                        point: LatLng(e.lat!, e.lng!),
                                        builder: (ctx) => DataMarker(),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                CircleLayerWidget(
                                  options: CircleLayerOptions(
                                    circles: [
                                      CircleMarker(
                                          point: locationState.locationData,
                                          color: Colors.blue.shade50
                                              .withOpacity(0.7),
                                          useRadiusInMeter: true,
                                          radius: calculatorMeterState.meter),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          else
                            return Container();
                        },
                      ),
                    if (online)
                      MarkerLayerWidget(
                        options: MarkerLayerOptions(markers: [
                          Marker(
                            width: locationState.accuracy <= 60
                                ? locationState.accuracy
                                : 20,
                            height: locationState.accuracy <= 60
                                ? locationState.accuracy
                                : 20,
                            point: locationState.locationData,
                            builder: (ctx) => UserMarker(
                              isMock: locationState.isMock,
                              accuracy: locationState.accuracy,
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
                if (loginState is LoginUserState)
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              online ? Colors.red : Colors.blue)),
                      onPressed: () {
                        if (online == true) {
                          context.read<LoginBloc>().add(LoginOfflineEvent());
                          setState(() {
                            online = false;
                          });
                        } else {
                          context.read<LoginBloc>().add(LoginOnlineEvent());

                          setState(() {
                            online = true;
                          });
                        }
                      },
                      child: Text(online ? "Not Login" : "Login"),
                    ),
                  )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _animatedMapMove(locationState.locationData, 17.0);
              },
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ); //loading event
    }
  }
}
