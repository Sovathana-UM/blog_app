import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    // Better implementation of rounded dashed rect:
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, x, y),
      const Radius.circular(12),
    );
    Path path = Path()..addRRect(rect);

    Path dashPath = Path();
    for (ui.PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < measurePath.length) {
        final double length = draw
            ? gap
            : gap; // Use gap for both dash and space
        dashPath.addPath(
          measurePath.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
