import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/bacground/data/data_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/compenent/userMarker.dart';

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
            return BlocProvider(
              create: (context) => DataBloc()..add(DataInitialEvent()),
              child: BlocBuilder<DataBloc, DataState>(
                builder: (context, dataState) {
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
                        if(dataState is DataSetState)
                        MarkerLayerOptions(
                          markers:dataState.data,
                        ),
                        MarkerLayerOptions(markers: [
                          Marker(
                            width: state.accuracy,
                            height: state.accuracy,
                            point: state.locationData,
                            builder: (ctx) => UserMarker(
                              accuracy: state.accuracy,
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
                        controller.move(state.locationData, 17.0);
                      },
                    ),
                  );
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
