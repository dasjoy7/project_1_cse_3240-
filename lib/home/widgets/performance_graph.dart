import 'package:flutter/material.dart';
import '../home_models.dart';

class PerformanceGraph extends StatelessWidget {
  final UserProfile profile;

  const PerformanceGraph({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final total = profile.easySolve + profile.mediumSolve + profile.hardSolve;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Performance',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E)),
              ),
              const Spacer(),
              Text(
                '$total solved',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No problems solved yet',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            )
          else ...[
            // Circular donut + legend side by side
            Row(
              children: [
                // Donut chart (custom paint)
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      easy: profile.easySolve,
                      medium: profile.mediumSolve,
                      hard: profile.hardSolve,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'solved',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Legend + bars
                Expanded(
                  child: Column(
                    children: [
                      _difficultyRow('Easy', profile.easySolve, total,
                          const Color(0xFF43A047)),
                      const SizedBox(height: 12),
                      _difficultyRow('Medium', profile.mediumSolve, total,
                          const Color(0xFFFFA726)),
                      const SizedBox(height: 12),
                      _difficultyRow('Hard', profile.hardSolve, total,
                          const Color(0xFFE53935)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _difficultyRow(
      String label, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            Text('$count',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int easy;
  final int medium;
  final int hard;

  _DonutPainter(
      {required this.easy, required this.medium, required this.hard});

  @override
  void paint(Canvas canvas, Size size) {
    final total = (easy + medium + hard).toDouble();
    if (total == 0) return;

    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    const strokeWidth = 14.0;

    final segments = [
      (easy / total, const Color(0xFF43A047)),
      (medium / total, const Color(0xFFFFA726)),
      (hard / total, const Color(0xFFE53935)),
    ];

    double startAngle = -3.14159 / 2; // start from top

    for (final seg in segments) {
      if (seg.$1 == 0) continue;
      final sweepAngle = seg.$1 * 2 * 3.14159;
      final paint = Paint()
        ..color = seg.$2
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFEEF0F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw gaps between segments as background
    if (total > 0) {
      // already drawn
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.easy != easy || old.medium != medium || old.hard != hard;
}