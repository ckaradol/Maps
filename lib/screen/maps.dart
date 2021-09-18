import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/compenent/dataMarker.dart';
import 'package:map/compenent/userMarker.dart';
import 'package:map/compenent/zoombuttons_plugin_option.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc()
        ..add(LocationInitialEvent()), //data provider locationBloc starts first
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          // SetStated field when location Bloc state changes
          if (state is LocationSetState) {
            LoginState loginState = context.read<LoginBloc>().state;
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
                          center: state.locationData,
                          zoom: 5.0,
                          plugins: [
                            ZoomButtonsPlugin(),
                          ],
                        ),
                        layers: [
                          TileLayerOptions(
                            maxZoom: 18.9,
                            maxNativeZoom: 18.9,
                            minNativeZoom: 4,
                            minZoom: 4,
                            zoomReverse: false,
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          if (loginState is LoginCenterState)
                            MarkerLayerOptions(
                              markers: loginState.marker!.map((e) {
                                return Marker(
                                  width: 80,
                                  height: 80,
                                  point: LatLng(e.lat!, e.lng!),
                                  builder: (ctx) => DataMarker(),
                                );
                              }).toList(),
                            ),
                          if (online)
                            MarkerLayerOptions(markers: [
                              Marker(
                                width:
                                    state.accuracy <= 60 ? state.accuracy : 20,
                                height:
                                    state.accuracy <= 60 ? state.accuracy : 20,
                                point: state.locationData,
                                builder: (ctx) => UserMarker(
                                  isMock: state.isMock,
                                  accuracy: state.accuracy,
                                ),
                              ),
                            ]),
                        ],
                        nonRotatedLayers: [
                          ZoomButtonsPluginOption(
                            mini: true,
                            padding: 10,
                            alignment: Alignment.bottomLeft,
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
                                context
                                    .read<LoginBloc>()
                                    .add(LoginOfflineEvent());
                                setState(() {
                                  online = false;
                                });
                              } else {
                                context
                                    .read<LoginBloc>()
                                    .add(LoginOnlineEvent());

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
                      _animatedMapMove(state.locationData, 17.0);
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
        },
      ),
    );
  }
}
