import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';

part 'calculator_meter_network_event.dart';
part 'calculator_meter_network_state.dart';

class CalculatorMeterNetworkBloc
    extends Bloc<CalculatorMeterNetworkEvent, CalculatorMeterNetworkState> {
  CalculatorMeterNetworkBloc() : super(CalculatorMeterNetworkInitial());

  @override
  Stream<CalculatorMeterNetworkState> mapEventToState(
    CalculatorMeterNetworkEvent event,
  ) async* {
    if (event is InitialEvent) {
      List<DataModel> dataModel = [];
      try {
        FirebaseDatabase.instance.goOnline(); //database online
        var db = FirebaseDatabase.instance
            .reference()
            .child("userLocation"); //database location
        if (dataModel.isEmpty) {
          db.get().asStream().forEach((doc) {
            if (doc.exists) {
              if (doc.value["connect"] == true) {
                dataModel.add(DataModel.fromJson(
                    doc.value as Map<dynamic, dynamic>, doc.key!));
              }
            }
            add(SetEvent(dataModel));
          });
        }
        db.onChildAdded.forEach((doc) {
          //database added listen
          if (doc.snapshot.exists) {
            if (doc.snapshot.value["connect"] == true) {
              dataModel.add(DataModel.fromJson(
                  doc.snapshot.value as Map<dynamic, dynamic>,
                  doc.snapshot.key!));
            }
          }
          add(SetEvent(dataModel));
        });
        db.onChildChanged.forEach((doc) {
          //database changed listen
          if (doc.snapshot.exists) {
            dataModel.remove(DataModel.fromJson(
                doc.snapshot.value as Map<dynamic, dynamic>,
                doc.snapshot.key!));
            if (doc.snapshot.value["connect"] == true) {
              dataModel.add(DataModel.fromJson(
                  doc.snapshot.value as Map<dynamic, dynamic>,
                  doc.snapshot.key!));
            }
          }
          add(SetEvent(dataModel));
        });
        db.onChildRemoved.forEach((doc) {
          //database removed listen
          if (doc.snapshot.exists) {
            dataModel.remove(DataModel.fromJson(
                doc.snapshot.value as Map<dynamic, dynamic>,
                doc.snapshot.key!));
          }
          add(SetEvent(dataModel));
        });
      } on Exception catch (e) {}
    }
    if (event is SetEvent) {
      yield CalculatorMeterNetworkListen(event.data);
    }
  }
}
