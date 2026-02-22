import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems/screens/problem_detail_page.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart'; 

/// Helper to build consistent section titles (e.g., PERFORMANCE STATS)
Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title.toUpperCase(), 
      style: TextStyle(color: Colors.blueGrey[500], fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
  );
}

/// The top profile bar showing the user's name and avatar.
Widget buildHeader(String name) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withOpacity(0.1), width: 4),
          ),
          child: const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.face_retouching_natural_rounded, color: Color(0xFF2563EB), size: 32),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("G'DAY ATHLETE,", style: TextStyle(color: Colors.blueGrey[400], fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              Text(name, 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12)),
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active_outlined, color: Colors.blueGrey, size: 24)),
        ),
      ],
    ),
  );
}

/// A horizontal card showing key metrics like Rating and Solved count.
Widget buildStatsCard(String rating, String solved) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(rating, "Rating", Icons.bolt_rounded, Colors.amber),
        StatItem(solved, "Solved", Icons.check_circle_outline_rounded, Colors.green),
        const StatItem("Top 5%", "Global", Icons.public_rounded, Colors.blueAccent),
      ],
    ),
  );
}

/// The prominent blue gradient card for the Problem of the Day.
Widget buildFeaturedChallenge(BuildContext context, Map<String, dynamic> problemMap, String title, String points) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
      ),
      boxShadow: [
        BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))
      ]
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: const Text("DAILY CHALLENGE", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
            ),
            Text("+$points Points", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (problemMap.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProblemDetailPage(
                      problem: Problem.fromMap(problemMap), 
                      title: title,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16)
            ),
            child: const Text("START CHALLENGE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        )
      ],
    ),
  );
}

/// Visual representation of the user's daily activity streak.
Widget buildStreakSection(String streak) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      border: Border.all(color: Colors.orange.withOpacity(0.1)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$streak Day Streak!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text("Don't let the fire go out today!", style: TextStyle(color: Colors.blueGrey[500], fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}

/// A row of three cards showing submission success rates.
Widget buildPerformanceSection(String total, String accepted, String wrong) {
  return Row(
    children: [
      performanceCard("Sent", total, const Color(0xFF64748B)), 
      const SizedBox(width: 12),
      performanceCard("Pass", accepted, const Color(0xFF10B981)), 
      const SizedBox(width: 12),
      performanceCard("Fail", wrong, const Color(0xFFEF4444)), 
    ],
  );
}

/// Individual card used inside the Performance Section.
Widget performanceCard(String label, String value, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white), 
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: TextStyle(color: Colors.blueGrey[400], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    ),
  );
}

/// A grid-like row displaying unlocked badges/achievements.
Widget buildBadgesSection() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        badgeItem("Alpha", Icons.auto_awesome_rounded, Colors.amber),
        badgeItem("Sage", Icons.psychology_rounded, Colors.indigo),
        badgeItem("Streak", Icons.whatshot_rounded, Colors.orange),
        badgeItem("Elite", Icons.workspace_premium_rounded, Colors.green),
      ],
    ),
  );
}

/// Individual badge icon with a label.
Widget badgeItem(String label, IconData icon, Color color) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), 
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      const SizedBox(height: 10),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
    ],
  );
}

/// A small reusable widget for stats with an icon (Rating, Solved, etc.).
class StatItem extends StatelessWidget {
  final String val, label;
  final IconData icon;
  final Color color;
  const StatItem(this.val, this.label, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        Text(label.toUpperCase(), style: TextStyle(color: Colors.blueGrey[400], fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }
}