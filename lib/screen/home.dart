import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:map/bacground/calculatorMeter/calculator_meter_bloc.dart';
import 'package:map/bacground/calculatorMeterNetwork/calculator_meter_network_bloc.dart';
import 'package:map/bacground/location/location_bloc.dart';
import 'package:map/compenent/loadingScreen.dart';
import 'package:map/screen/maps.dart';

import 'errorScreen.dart';
import 'loginScreen.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if(state ==AppLifecycleState.detached){
     exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        print(state);
        if (state is LoginNullState) {
          return LoginScreen();
        } else if (state is LoginUserState || state is LoginCenterState) {
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              if (locationState is LocationSetState) {
                return BlocProvider(
                  create: (context) => CalculatorMeterBloc()
                    ..add(InitialCalculatorMeter(
                        zoom: 17,
                        location: locationState.locationData,
                        data: state is LoginCenterState ? state.marker! : [])),
                  child: BlocProvider(
                    create: (context) =>
                        CalculatorMeterNetworkBloc()..add(InitialEvent()),
                    child: Maps(),
                  ),
                );
              } else {
                return LoadingScreen();
              }
            },
          );
        } else if (state is LoginErrorState) {
          return ErrorScreen();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
