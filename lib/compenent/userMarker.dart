import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:map/compenent/paintTriangle.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMarker extends StatelessWidget {
  final double accuracy;
  final bool? isMock;
  const UserMarker({
    Key? key,
    required this.accuracy,
    required this.isMock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: isMock == false ? 20 : accuracy,
        height: isMock == false ? 20 : accuracy,
        decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(100)),
        child: Icon(
          Icons.circle,
          color: isMock == true ? Colors.grey : Colors.blue,
          size: 20,
        ));
  }
}
/*
Container(
                width: isMock == false ? 20 : accuracy,
                height: isMock == false ? 20 : accuracy,
                decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  Icons.circle,
                  color: isMock == true ? Colors.grey : Colors.blue,
                  size: 20,
                )),
 */
