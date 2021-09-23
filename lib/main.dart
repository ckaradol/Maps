import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/screen/home.dart';
import 'package:map/screen/ErrorPopUpScreen.dart';
import 'bacground/Login/login_bloc.dart';
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
        create: (context) => LoginBloc()..add(LoginNullEvent()),
        child: BlocProvider(
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
                        content: ErrorPopUpScreen(
                          error:
                              "Network Error Mobile Network or Wifi Network Connecting Please",
                        ),
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
      ),
    );
  }
}
