import 'package:flutter/material.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/screen/loginScreen.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool willPop = false;

  @override
  Widget build(BuildContext context) {
    LoginState state = context.read<LoginBloc>().state;
    if (willPop == true) {
      return LoginScreen();
    }

    if (state is LoginErrorState) {
      return WillPopScope(
        onWillPop: () {
          setState(() {
            willPop = true;
          });
          return Future.value(false);
        },
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 45,
                  ),
                ),
              ),
              Text(
                state.error,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
