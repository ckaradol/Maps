import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/screen/errorScreen.dart';
import 'package:map/screen/loginScreen.dart';
import 'package:map/screen/maps.dart';
import 'package:map/screen/networkErrorScreen.dart';

import 'bacground/Login/login_bloc.dart';
import 'bacground/calculatorMeter/calculator_meter_bloc.dart';
import 'bacground/location/location_bloc.dart';
import 'bacground/networkConnectivity/connectivity_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => LocationBloc()..add(LocationInitialEvent()),
        child: BlocProvider(
            create: (context) =>
                ConnectivityBloc()..add(ConnectivityInitialEvent()),
            child: BlocListener<ConnectivityBloc, ConnectNetwork>(
              listener: (context, state) {
                if (state == ConnectNetwork.None) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Network Error"),
                      content: NetworkErrorScreen(),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Ok"))
                      ],
                    ),
                  );
                }
              },
              child: Home(),
            )),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocationState locationState = context.read<LocationBloc>().state;
    return BlocProvider(
      create: (context) => LoginBloc()..add(LoginNullEvent()),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginNullState) {
            return LoginScreen();
          } else if (state is LoginUserState || state is LoginCenterState) {
            if (locationState is LocationSetState) {
              return BlocProvider(
                create: (context) => CalculatorMeterBloc()
                  ..add(InitialCalculatorMeter(
                      zoom: 17,
                      location: locationState.locationData,
                      data: state is LoginCenterState ? state.marker! : [])),
                child: Maps(),
              );
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          } else if (state is LoginErrorState) {
            return ErrorScreen();
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
