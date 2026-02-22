import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerMenuModel {
  final String title;
  final IconData icon;
  final int? index; 
  final bool hasBadge;
  final Color? color;

  DrawerMenuModel({required this.title, required this.icon, this.index, this.hasBadge = false, this.color});
}

class DrawerService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDrawerData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};
      final response = await _supabase.from('profile').select('full_name, student_class').eq('id', user.id).maybeSingle();
      return {"name": response?['full_name'] ?? "Math Athlete", "class": response?['student_class'] ?? "N/A"};
    } catch (e) { return {}; }
  }

  List<DrawerMenuModel> getNavigationItems() {
    return [
      DrawerMenuModel(title: "Home", icon: Icons.home_rounded, index: 0),
      DrawerMenuModel(title: "Problems", icon: Icons.assignment_rounded, index: 1),
      DrawerMenuModel(title: "Leaderboard", icon: Icons.leaderboard_rounded, index: 2),
      DrawerMenuModel(title: "Contest", icon: Icons.emoji_events_rounded, index: 3, hasBadge: true),
      DrawerMenuModel(title: "AI Tutor", icon: Icons.psychology_rounded, index: 5, color: Colors.blue),
    ];
  }
}