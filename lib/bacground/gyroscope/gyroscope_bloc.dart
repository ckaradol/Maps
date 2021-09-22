import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:meta/meta.dart';

part 'gyroscope_event.dart';
part 'gyroscope_state.dart';

class GyroscopeBloc extends Bloc<GyroscopeEvent, GyroscopeState> {
  GyroscopeBloc() : super(GyroscopeInitial());

  @override
  Stream<GyroscopeState> mapEventToState(
    GyroscopeEvent event,
  ) async* {
    if(event is GyroscopeInitialEvent){
      try {
        if (FlutterCompass.events != null) {
          FlutterCompass.events!.listen((event) {
            if (event.heading != null) {
              add(GyroscopeSetStateEvent(event: event.heading!));
            } else {
              add(GyroscopeErrorEvent(
                  gyroscopeError: "Device does not have sensors !"));
            }
          });
        }
      } on Exception catch(e){
        add(GyroscopeErrorEvent(
            gyroscopeError: e.toString()));
      }
    }
    if(event is GyroscopeSetStateEvent){
      yield GyroscopeSetStateState(event: event.event);
    }
    if(event is GyroscopeErrorEvent){
      yield GyroscopeErrorState(error:event.gyroscopeError );
    }

  }
}
