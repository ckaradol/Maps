import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';

part 'calculator_meter_network_mark_event.dart';
part 'calculator_meter_network_mark_state.dart';

class CalculatorMeterNetworkMarkBloc extends Bloc<CalculatorMeterNetworkMarkEvent, CalculatorMeterNetworkMarkState> {
  CalculatorMeterNetworkMarkBloc() : super(CalculatorMeterNetworkMarkInitial());

  @override
  Stream<CalculatorMeterNetworkMarkState> mapEventToState(
    CalculatorMeterNetworkMarkEvent event,
  ) async* {
    if (event is InitialMarkEvent) {
      List<DataModel> dataModel = [];
      try {
        FirebaseDatabase.instance.goOnline(); //database online
        var db = FirebaseDatabase.instance
            .reference()
            .child("markLocation"); //database location
        db.onChildAdded.forEach((doc) {
          //database added listen
          if (doc.snapshot.exists) {
            if (doc.snapshot.value["connect"] == true) {
              if(doc.snapshot.value["lat"]!=null&&doc.snapshot.value["lng"]!=null) {
                dataModel.add(DataModel.fromJson(
                    doc.snapshot.value as Map<dynamic, dynamic>,
                    doc.snapshot.key!));
              }
            }
          }
          add(SetMarkEvent(dataModel));
        });
        db.onChildChanged.forEach((doc) {
          //database changed listen
          if (doc.snapshot.exists) {

            dataModel.remove(DataModel.fromJson(
                doc.snapshot.value as Map<dynamic, dynamic>,
                doc.snapshot.key!));
            if (doc.snapshot.value["connect"] == true) {
              if(doc.snapshot.value["lat"]!=null&&doc.snapshot.value["lng"]!=null) {
                dataModel.add(DataModel.fromJson(
                    doc.snapshot.value as Map<dynamic, dynamic>,
                    doc.snapshot.key!));
              }
            }
          }
          add(SetMarkEvent(dataModel));
        });
        db.onChildRemoved.forEach((doc) {
          //database removed listen
          if (doc.snapshot.exists) {
            if(doc.snapshot.value["lat"]!=null&&doc.snapshot.value["lng"]!=null) {
              dataModel.remove(DataModel.fromJson(
                  doc.snapshot.value as Map<dynamic, dynamic>,
                  doc.snapshot.key!));
            }
          }
          add(SetMarkEvent(dataModel));
        });
      } on Exception catch (e) {}
    }
    if (event is SetMarkEvent) {
      yield CalculatorMeterNetworkMarkListen(event.data);
    }
  }
}
