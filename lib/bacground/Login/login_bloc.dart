import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';
/*
db.get().then((data) {
        print(data);
        dataModel
            .add(DataModel.fromJson(data.value as Map<dynamic, dynamic>, data.key!));
        add(LoginSetStateEvent(center: true,marker: dataModel));
      });
      db.onChildChanged.forEach((data) {
        dataModel.remove(data.snapshot.key);
        dataModel
            .add(DataModel.fromJson(data.snapshot.value as Map<dynamic, dynamic>, data.snapshot.key!));
        add(LoginSetStateEvent(center: true,marker: dataModel));
      });
      db.onChildAdded.forEach((data) {
        dataModel
            .add(DataModel.fromJson(data.snapshot.value as Map<dynamic, dynamic>, data.snapshot.key!));
        add(LoginSetStateEvent(center: true,marker: dataModel));
      });
      db.onChildRemoved.forEach((data) {
        dataModel.remove(data.snapshot.key);
        add(LoginSetStateEvent(center: true,marker: dataModel));
      });
 */
part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginCenterEvent) {
      var db = FirebaseDatabase.instance.reference().child("userLocation").orderByKey();
      List<DataModel> dataModel = [];
      FirebaseFirestore.instance.collection("userLocation").snapshots().forEach((docs) {
        docs.docChanges.forEach((doc) {
          if(doc.doc.exists){
            if(doc.type==DocumentChangeType.added){
           if(doc.doc.data()!["connect"]==true){
             dataModel
                 .add(DataModel.fromJson(doc.doc.data()!, doc.doc.id));
             if(state is LoginCenterState){
               add(LoginSetStateEvent(center: true, marker: dataModel));
             }
           }
            }
            if(doc.type==DocumentChangeType.removed){
              dataModel.remove(doc.doc.id);
            }
            if(doc.type==DocumentChangeType.modified){
              dataModel.remove(doc.doc.id);
             if(doc.doc.data()!["connect"]==true){
               dataModel
                   .add(DataModel.fromJson(doc.doc.data()!, doc.doc.id));
               if(state is LoginCenterState){
                 add(LoginSetStateEvent(center: true, marker: dataModel));
               }
             }
            }
          }
        });
      });
      add(LoginSetStateEvent(center: true, marker: dataModel));
    }
    if (event is LoginUserEvent) {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();

      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user == null) {
          add(LoginNullEvent());
        } else {
          String userId = user.uid;
          Location location = Location();


          bool _serviceEnabled;
          PermissionStatus _permissionGranted;

          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              return;
            }
          }

          _permissionGranted = await location.hasPermission();
          if (_permissionGranted == PermissionStatus.denied) {
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
              return;
            }
          }
          location.onLocationChanged
              .listen((LocationData currentLocation) async {
            if (currentLocation.isMock == false) {
              if(user!=null) {
                FirebaseFirestore.instance.collection("userLocation").doc(userId).set({
                  "connect": true,
                  "lat": currentLocation.latitude,
                  "lng": currentLocation.longitude
                });
              }
            }
          });
          add(LoginSetStateEvent(center: false, marker: null));
        }
      });
    }
    if (event is LoginSetStateEvent) {
      print(event.center);
      if (event.center) {

        yield LoginCenterState(event.marker);
      } else {
        yield LoginUserState();
      }
    }
    if (event is LoginNullEvent) {


      yield LoginNullState();
    }
  }
}
