import 'package:flutter/material.dart';

class UserMarker extends StatelessWidget {
  final double accuracy;
  const UserMarker({
    Key? key,required this.accuracy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: accuracy,
        height: accuracy,
        decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(100)
        ),
        child: Icon(Icons.circle,color: Colors.blue,size: 20,)
    );
  }
}
