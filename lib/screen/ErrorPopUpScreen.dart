import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bacground/Login/login_bloc.dart';

class ErrorPopUpScreen extends StatelessWidget {
  final String error;

  const ErrorPopUpScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 45,
          ),
        ),
        Text(
          error,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
