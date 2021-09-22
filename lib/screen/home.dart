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

class Home extends StatelessWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc()..add(LoginNullEvent()),
      child: BlocBuilder<LoginBloc, LoginState>(
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
                          data:
                          state is LoginCenterState ? state.marker! : [])),
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
      ),
    );
  }
}
