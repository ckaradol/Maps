import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';

part 'connectivity_event.dart';

enum ConnectNetwork {
  ConnectivityLoading,
  Mobile,
  None,
  Wifi,
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectNetwork> {
  ConnectivityBloc() : super(ConnectNetwork.ConnectivityLoading);

  @override
  Stream<ConnectNetwork> mapEventToState(
    ConnectivityEvent event,
  ) async* {
    if (event is ConnectivityInitialEvent) {
      Connectivity connectivity = Connectivity();
      ConnectivityResult result = await connectivity.checkConnectivity();
      add(ConnectivityChecked(result));
      connectivity.onConnectivityChanged.listen((connect) {
        add(ConnectivityChecked(connect));
      });
    }
    if (event is ConnectivityChecked) {
      if (event.result == ConnectivityResult.none) {
        yield ConnectNetwork.None;
      } else if (event.result == ConnectivityResult.mobile) {
        yield ConnectNetwork.Mobile;
      } else if (event.result == ConnectivityResult.wifi) {
        yield ConnectNetwork.Wifi;
      }
    }
  }
}
