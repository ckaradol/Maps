import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:map/bacground/calculatorMeter/calculator_meter_bloc.dart';
import 'package:map/bacground/calculatorMeterNetwork/calculator_meter_network_bloc.dart';
import 'package:map/bacground/calculatorMeterNetworkMark/calculator_meter_network_mark_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:map/compenent/buildDataMarkers.dart';
import 'package:map/compenent/circleCalculatorMeterWidget.dart';
import 'package:map/compenent/loadingScreen.dart';
import 'package:map/compenent/showDialogInfo.dart';
import 'package:map/compenent/userMarker.dart';
import 'package:map/compenent/userGyroscopeMarkerLayerWidget.dart';
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
    // The animation determines what path the animation will take. You can try different Curves values
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
      context.read<LoginBloc>().add(LoginOfflineEvent());
      FirebaseAuth.instance.signOut(); //firebase signOut
    }
    if (loginState is LoginCenterState) {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var db = FirebaseDatabase.instance
            .reference()
            .child("markLocation")
            .child(user.uid);

        db.update({
          "connect": false,
        });
        FirebaseAuth.instance.signOut(); //firebase signOut
      }
    }
    context
        .read<LoginBloc>()
        .add(LoginNullEvent()); //login event is the return login screen active
    return false;
  }

  bool online = true;

  double km = 300;

  Distance distance = Distance();

  @override
  void initState() {
    super.initState();
    LocationState locationState = context.read<LocationBloc>().state;

    if (locationState is LocationSetState)
      mapController.mapEventStream.forEach((map) {
        context.read<CalculatorMeterBloc>().add(SetMeterEvent(
            location: locationState.locationData, data: [], zoom: map.zoom));
      }); //mapController listener and
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
          child: BlocBuilder<CalculatorMeterNetworkBloc,
              CalculatorMeterNetworkState>(
            builder: (context, calculatorMeterNetworkState) {
              return Scaffold(
                bottomNavigationBar: loginState is LoginCenterState
                    ? calculatorMeterNetworkState
                            is CalculatorMeterNetworkListen
                        ? SizedBox.fromSize(
                            size: Size.fromHeight(50),
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Aktif Kullanıcı Sayısı: ${calculatorMeterNetworkState.data.length}",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                    Builder(builder: (context) {
                                      List<DataModel> data = [];
                                      for (var model
                                          in calculatorMeterNetworkState.data) {
                                        if (model.lat != null &&
                                            model.lng != null) {
                                          LatLng user =
                                              LatLng(model.lat!, model.lng!);
                                          Distance distance = Distance();
                                          double userMeter = distance.as(
                                              LengthUnit.Meter,
                                              user,
                                              locationState
                                                  .locationData); //latlng 1 and latlng2 calculate meters between
                                          CalculatorMeterState state = context
                                              .read<CalculatorMeterBloc>()
                                              .state;
                                          if (state is SetMeter) if (userMeter <=
                                              state.meter) {
                                            data.add(model);
                                          }
                                        }
                                      }
                                      return Expanded(
                                        child: Text(
                                          "Alan Aktif Kullanıcı Sayısı: ${data.length}",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ),
                            ),
                          )
                        : null
                    : null,
                body: Stack(
                  children: [
                    BlocBuilder<CalculatorMeterBloc, CalculatorMeterState>(
                      builder: (context, calculatorMeterState) {
                        if (calculatorMeterState is SetMeter)
                          return FlutterMap(
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
                              CircleCalculatorMeterWidget(
                                  locationData: locationState.locationData),
                              if (online)
                                if (locationState.isMock == false)
                                  CircleLayerWidget(
                                    options: CircleLayerOptions(
                                      circles: [
                                        CircleMarker(
                                            color: Colors.blue[200]!
                                                .withOpacity(0.5),
                                            point: locationState.locationData,
                                            radius: locationState.accuracy,
                                            useRadiusInMeter: true)
                                      ],
                                    ),
                                  ),
                              if (online)
                                MarkerLayerWidget(
                                  options: MarkerLayerOptions(
                                    markers: [
                                      Marker(
                                        width: 20,
                                        height: 20,
                                        point: locationState.locationData,
                                        builder: (ctx) => UserMarker(
                                          isMock: locationState.isMock,
                                          accuracy: locationState.accuracy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (online)
                                UserGyroscopeMarkerLayerWidget(
                                    locationData: locationState.locationData),
                              if (loginState is LoginCenterState)
                                if (calculatorMeterNetworkState
                                    is CalculatorMeterNetworkListen)
                                  BuildDataMarkers(
                                      locationData: locationState.locationData,
                                      calculatorMeter:
                                          calculatorMeterState.meter,
                                      stateData:
                                          calculatorMeterNetworkState.data),
                              if (loginState is LoginUserState)
                                BlocProvider(
                                  create: (context) =>
                                      CalculatorMeterNetworkMarkBloc()
                                        ..add(InitialMarkEvent()),
                                  child: BlocBuilder<
                                      CalculatorMeterNetworkMarkBloc,
                                      CalculatorMeterNetworkMarkState>(
                                    builder: (context,
                                        calculatorMeterNetworkMarkState) {
                                      print(calculatorMeterNetworkMarkState);

                                      if (calculatorMeterNetworkMarkState
                                          is CalculatorMeterNetworkMarkListen) {
                                        return BuildDataMarkers(
                                            locationData:
                                                locationState.locationData,
                                            calculatorMeter:
                                                calculatorMeterState.meter,
                                            stateData:
                                                calculatorMeterNetworkMarkState
                                                    .data);
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                            ],
                          );
                        else
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                      },
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
                              context
                                  .read<LoginBloc>()
                                  .add(LoginOfflineEvent());
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
                          child: Text(online ? "Aktif Değil" : "Aktif"),
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
              );
            },
          ),
        ),
      );
    } else {
      return LoadingScreen(); //loading event
    }
  }
}
