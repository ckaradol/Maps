import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/compenent/showDialogInfo.dart';

import 'dataMarker.dart';

class BuildDataMarkers extends StatelessWidget {
  final double calculatorMeter;
  const BuildDataMarkers({
    Key? key,
    required this.locationData,required this.calculatorMeter,required this.stateData,
  }) : super(key: key);
  final List<DataModel>stateData;
  final LatLng locationData;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      List<DataModel> data = [];
      for (var model in stateData) {
        if (model.lat != null &&
            model.lng != null) {
          LatLng user =
          LatLng(model.lat!, model.lng!);
          Distance distance = Distance();
          double userMeter = distance.as(
              LengthUnit.Meter,
              user, locationData); //latlng 1 and latlng2 calculate meters between
          if (userMeter <=
              calculatorMeter) {
            data.add(model);
          }
        }
      }
      return MarkerLayerWidget(

        options: MarkerLayerOptions(
          markers: data.map((e) {
            return Marker(
              width: 80,
              height: 80,
              point: LatLng(e.lat!, e.lng!),
              builder: (ctx) => Container(
                child: GestureDetector(
                    onTap: (){
                      LatLng user =
                      LatLng(e.lat!, e.lng!);
                      Distance distance = Distance();
                      double userMeter = distance.as(
                          LengthUnit.Meter,
                          user, locationData);
                      showDialog(context: context, builder: (context)=>ShowDialogInfo(title: "User Info",content: Text("$userMeter meters away"),));
                    },
                    child: DataMarker()),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}