import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/animation.dart';
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
      try {
     await   FirebaseDatabase.instance.goOnline(); //connect database
        UserCredential userCredential= await FirebaseAuth.instance.signInAnonymously();
        var db = FirebaseDatabase.instance.reference().child("markLocation");
        if(userCredential.user!=null){
          db.child(userCredential.user!.uid).get().then((doc) {
            if(doc.exists){
              if(doc.value["connect"]==false){
                db.child(userCredential.user!.uid).set({
                  "connect":true
                });
              }
            }
          });
        }
        if (userCredential.user == null) {
          add(LoginNullEvent());
        } else {
          try {
            String userId = userCredential.user!.uid;
            db.child(userCredential.user!.uid).onDisconnect().update({"connect": false});
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
            add(LoginSetStateEvent(center: true, marker: []));
          } on FirebaseException catch (e) {
            add(LoginErrorEvent(e.message!));
          }
        }
      } on FirebaseAuthException catch (e) {
        add(LoginErrorEvent(e.message!));
      }

    }
    if (event is LoginUserEvent) {
      yield LoginLoadingState();
      try {
        await  FirebaseDatabase.instance.goOnline(); //connect database
       UserCredential userCredential= await FirebaseAuth.instance.signInAnonymously();
        var db = FirebaseDatabase.instance.reference().child("userLocation");
        if(userCredential.user!=null){
          db.child(userCredential.user!.uid).get().then((doc) {
            if(doc.exists){
              if(doc.value["connect"]==false){
                db.child(userCredential.user!.uid).set({
                  "connect":true
                });
              }
            }
          });
        }
          if (userCredential.user == null) {
            add(LoginNullEvent());
          } else {
            try {
              String userId = userCredential.user!.uid;
              db.child(userCredential.user!.uid).onDisconnect().update({"connect": false});
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
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var db = FirebaseDatabase.instance
            .reference()
            .child("userLocation")
            .child(user.uid);

        db.update({
          "connect": false,
        });
      }
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
