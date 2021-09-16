import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/location/location_bloc.dart';

class Maps extends StatefulWidget {
  Maps({
    Key? key,
  }) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc()..add(LocationInitialEvent()),
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationSetState) {
            return Scaffold(
              body: FlutterMap(
                mapController: controller,
                options: MapOptions(
                  center: state.locationData,
                  zoom: 5.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 10,
                        height: 10,
                        point: LatLng(51.5, -0.09),
                        builder: (ctx) => Container(
                          width: 5,
                          height: 5,
                          child: FlutterLogo(),
                        ),
                      ),
                    ],
                  ),
                  MarkerLayerOptions(markers: [
                    Marker(
                      width: state.accuracy,
                      height: state.accuracy,
                      point: state.locationData,
                      builder: (ctx) => Container(
                        width: state.accuracy,
                        height: state.accuracy,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Icon(Icons.circle,color: Colors.blue,size: 5,)
                      ),
                    ),
                  ]),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.move(state.locationData, controller.zoom);
                },
              ),
            );
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
