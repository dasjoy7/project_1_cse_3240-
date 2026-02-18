import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final int easy;
  final int medium;
  final int hard;
  ProgressRing({
    super.key,
    required this.easy,
    required this.medium,
    required this.hard,
  });

  @override
  Widget build(BuildContext context) {
    final total = easy + medium + hard;
    final size = 150.0;
    return Row(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              easy: easy,
              medium: medium,
              hard: hard,
              total: total,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(total.toString(),
                    style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.pink),
                  ),
                  Text("SOLVED",
                    style: TextStyle(fontSize:12,color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width:10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _legend(Colors.blue,"Easy",easy),
            SizedBox(height:12),
            _legend(Colors.green,"Medium",medium),
            SizedBox(height:12),
            _legend(Colors.red,"Hard",hard),
          ],
        )
      ],
    );
  }

  Widget _legend(Color color,String label,int value) {
    return Row(
      children: [
        Container(
          width:15,
          height:15,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width:8),
        Text("$label $value"),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final int easy;
  final int medium;
  final int hard;
  final int total;
  _RingPainter({
    required this.easy,
    required this.medium,
    required this.hard,
    required this.total,
  });

  @override
  void paint(Canvas canvas,Size size) {
    final center=size.center(Offset.zero);
    final radius=size.width/2;
    const stroke=25.0;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center,radius-stroke/2,bgPaint);
    if(total == 0)return;
    double startAngle=-pi/2;
    void drawSegment(double value,Color color)
    {
      final sweep=(value/total)*2*pi;
      final paint=Paint()
        ..color=color
        ..style=PaintingStyle.stroke
        ..strokeWidth=stroke
        ..strokeCap=StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center,radius: radius-stroke/2),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle +=sweep;
    }
    drawSegment(easy.toDouble(),Colors.blue);
    drawSegment(medium.toDouble(),Colors.green);
    drawSegment(hard.toDouble(),Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>true;
}