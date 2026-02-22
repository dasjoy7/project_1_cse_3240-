import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressRing extends StatelessWidget {
  final int easy;
  final int medium;
  final int hard;

  const ProgressRing({
    super.key,
    required this.easy,
    required this.medium,
    required this.hard,
  });

  @override
  Widget build(BuildContext context) {
    int total = easy + medium + hard;
    
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            color: Colors.grey.withOpacity(0.1),
          ),
          // Ring Painter for Multi-colors
          CustomPaint(
            size: const Size(120, 120),
            painter: MultiSegmentPainter(
              easy: easy,
              medium: medium,
              hard: hard,
              total: total,
            ),
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$total",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Total",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MultiSegmentPainter extends CustomPainter {
  final int easy, medium, hard, total;

  MultiSegmentPainter({required this.easy, required this.medium, required this.hard, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final double strokeWidth = 10;
    final Rect rect = Offset(strokeWidth / 2, strokeWidth / 2) & 
                     Size(size.width - strokeWidth, size.height - strokeWidth);
    
    double startAngle = -math.pi / 2;

    // Easy (Green)
    _drawSegment(canvas, rect, startAngle, (easy / total), Colors.green, strokeWidth);
    startAngle += (easy / total) * 2 * math.pi;

    // Medium (Orange)
    _drawSegment(canvas, rect, startAngle, (medium / total), Colors.orange, strokeWidth);
    startAngle += (medium / total) * 2 * math.pi;

    // Hard (Red)
    _drawSegment(canvas, rect, startAngle, (hard / total), Colors.red, strokeWidth);
  }

  void _drawSegment(Canvas canvas, Rect rect, double startAngle, double sweepFactor, Color color, double strokeWidth) {
    if (sweepFactor == 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepFactor * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}