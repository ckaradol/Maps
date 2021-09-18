import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:map/bacground/model/dataModel.dart';
import 'package:meta/meta.dart';
part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginCenterEvent) {
      List<DataModel> dataModel = [];
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
      });
      db.onChildChanged.forEach((doc) {
        //database changed listen
        if (doc.snapshot.exists) {
          dataModel.remove(DataModel.fromJson(
              doc.snapshot.value as Map<dynamic, dynamic>, doc.snapshot.key!));
          if (doc.snapshot.value["connect"] == true) {
            dataModel.add(DataModel.fromJson(
                doc.snapshot.value as Map<dynamic, dynamic>,
                doc.snapshot.key!));
          }
        }
      });
      db.onChildRemoved.forEach((doc) {
        //database removed listen
        if (doc.snapshot.exists) {
          dataModel.remove(DataModel.fromJson(
              doc.snapshot.value as Map<dynamic, dynamic>, doc.snapshot.key!));
        }
      });
      add(LoginSetStateEvent(center: true, marker: dataModel));
    }
    if (event is LoginUserEvent) {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      var db = FirebaseDatabase.instance.reference().child("userLocation");

      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user == null) {
          add(LoginNullEvent());
        } else {
          FirebaseDatabase.instance.goOnline(); //connect database
          String userId = user.uid;
          db.child(user.uid).onDisconnect().update({"connect": false});
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
              db.child(userId).get().then((doc) {
                if (doc.exists) {
                  if (doc.value["connect"] == false) {
                    return false;
                  }
                  db.child(userId).set({
                    "connect": true,
                    "lat": currentLocation.latitude,
                    "lng": currentLocation.longitude
                  });
                } else {
                  db.child(userId).set({
                    "connect": true,
                    "lat": currentLocation.latitude,
                    "lng": currentLocation.longitude
                  });
                }
              });
            }
          });
          add(LoginSetStateEvent(center: false, marker: null));
        }
      });
    }
    if (event is LoginSetStateEvent) {
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
