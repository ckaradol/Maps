import 'dart:math';

import 'package:flutter/material.dart';

class PaintTriangle extends CustomPainter {
  late Paint painter;

  PaintTriangle() {
    painter = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();

    path.moveTo((size.width / 2), 20);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);

    path.close();

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
