import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bacground/Login/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            ElevatedButton(
              onPressed: () {
                context.read<LoginBloc>().add(LoginCenterEvent());
              },
              child: Text("Merkez"),
            ),
            Expanded(child: SizedBox()),
            ElevatedButton(
              onPressed: () {
                context.read<LoginBloc>().add(LoginUserEvent());
              },
              child: Text("Kullanıcı"),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
