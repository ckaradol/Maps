import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/location/location_bloc.dart';

class Maps extends StatelessWidget {
  const Maps({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc()..add(LocationInitialEvent()),
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          return Scaffold(
            body: FlutterMap(
              options: MapOptions(
                center: LatLng(51.5, -0.09),
                zoom: 13.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(51.5, -0.09),
                      builder: (ctx) => Container(
                        width: 5,
                        height: 5,
                        child: FlutterLogo(),
                      ),
                    ),
                  ],
                ),
                if (state is LocationSetState)
                  MarkerLayerOptions(markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(state.locationData.latitude!, state.locationData.longitude!),
                      builder: (ctx) => Container(
                        color: Colors.blue,
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
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}

