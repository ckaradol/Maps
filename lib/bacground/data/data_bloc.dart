import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:map/compenent/dataMarker.dart';
import 'package:meta/meta.dart';

part 'data_event.dart';

part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  DataBloc() : super(DataInitial());

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is DataInitialEvent) {
      List<Marker>dataMarker=[];
     List data=await rootBundle.loadString("assets/data.json").then((jsonStr) => jsonDecode(jsonStr));
     data.forEach((data) {
       DataModel dataModel=DataModel.fromJson(data);
       dataMarker.add(
       Marker(
         width: 80,
         height: 80,
         point:LatLng(dataModel.lat!,dataModel.lng!) ,
         builder: (ctx) => DataMarker(),
       ));
       add(DataSetStateEvent(dataMarker));
     });
    }
    if(event is DataSetStateEvent){
      yield DataSetState(event.marker);
    }
  }
}
