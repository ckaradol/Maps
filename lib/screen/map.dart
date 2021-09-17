import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/data/data_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/compenent/userMarker.dart';
import 'package:map/compenent/zoombuttons_plugin_option.dart';

class Maps extends StatefulWidget {
  Maps({
    Key? key,
  }) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> with TickerProviderStateMixin {
  final MapController mapController = MapController(); //MapController initialized
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc()..add(LocationInitialEvent()), //data provider locationBloc starts first
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          // SetStated field when location Bloc state changes
          if (state is LocationSetState) {
            return BlocProvider(
              create: (context) => DataBloc()..add(DataInitialEvent()), //data provider dataBloc starts first
              child: BlocBuilder<DataBloc, DataState>(
                builder: (context, dataState) {
                  // SetStated field when data Bloc state changes
                  return SafeArea(
                    child: Scaffold(
                      body: FlutterMap(
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
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          if (dataState is DataSetState)
                            MarkerLayerOptions(
                              markers: dataState.data,
                            ),
                          MarkerLayerOptions(markers: [
                            Marker(
                              width: state.accuracy<=60?state.accuracy:20,
                              height: state.accuracy<=60?state.accuracy:20,
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
                            minZoom: 4,
                            maxZoom: 19,
                            mini: true,
                            padding: 10,
                            alignment: Alignment.bottomLeft,
                          ),
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
                  );
                },
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
