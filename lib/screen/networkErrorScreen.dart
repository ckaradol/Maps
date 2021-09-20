import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bacground/Login/login_bloc.dart';

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
          "Network Error Mobile Network or Wifi Network Connecting Please",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
