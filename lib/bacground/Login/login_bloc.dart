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
      add(LoginSetStateEvent(center: true, marker: dataModel));
    }
    if (event is LoginUserEvent) {
      yield LoginLoadingState();
      try {
        await FirebaseAuth.instance.signInAnonymously();
        var db = FirebaseDatabase.instance.reference().child("userLocation");
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          if (user == null) {
            add(LoginNullEvent());
          } else {
            try {
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
              await location.enableBackgroundMode();
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
            } on FirebaseException catch (e) {
              add(LoginErrorEvent(e.message!));
            }
          }
        });
      } on FirebaseAuthException catch (e) {
        add(LoginErrorEvent(e.message!));
      }
    }
    if (event is LoginOnlineEvent) {
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          var db = FirebaseDatabase.instance
              .reference()
              .child("userLocation")
              .child(user.uid);
          FirebaseDatabase.instance.goOnline();
          db.onDisconnect().set({"connect": false});

          db.update({
            "connect": true,
          });
        } on FirebaseException catch (e) {
          add(LoginErrorEvent(e.message!));
        }
      } else {
        add(LoginNullEvent());
      }
    }
    if (event is LoginOfflineEvent) {
      FirebaseDatabase.instance.goOffline();
    }
    if (event is LoginSetStateEvent) {
      if (event.center) {
        yield LoginCenterState(event.marker);
      } else {
        yield LoginUserState();
      }
    }
    if (event is LoginErrorEvent) {
      yield LoginErrorState(event.error);
    }
    if (event is LoginNullEvent) {
      yield LoginNullState();
    }
  }
}
