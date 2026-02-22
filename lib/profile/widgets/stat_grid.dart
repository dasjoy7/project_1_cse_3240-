import 'package:flutter/material.dart';

class StatGrid extends StatelessWidget {
  final String points;
  final String solved;
  final String rank;

  const StatGrid({
    super.key, 
    required this.points, 
    required this.solved, 
    required this.rank
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statBox("Points", points, Colors.orange, Icons.stars_rounded),
        const SizedBox(width: 10),
        _statBox("Solved", solved, Colors.green, Icons.check_circle_rounded),
        const SizedBox(width: 10),
        _statBox("Rank", "#$rank", Colors.blue, Icons.leaderboard_rounded),
      ],
    );
  }

  Widget _statBox(String label, String val, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              val,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}