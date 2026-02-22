import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/daily_activity.dart';
import '../widgets/profile_header.dart';
import '../widgets/personal_details_card.dart';
import '../widgets/stat_grid.dart';
import '../widgets/submission_heatmap.dart';
import '../widgets/progress_ring.dart'; 
import 'submission_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final profileService = ProfileService();

  /// Fetches data from 'profile', 'user_profile_full', and 'user_submission_details'
  Future<Map<String, dynamic>> _getAllProfileData() async {
    final results = await Future.wait([
      profileService.getRealUserData(), // From 'profile'
      profileService.fetchUserStats(),  // From 'user_profile_full'
      profileService.fetchHeatmapData(), // From 'user_submission_details'
    ]);

    return {
      "user": results[0],
      "stats": results[1],
      "heatmap": results[2],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getAllProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text("Error loading profile"));

          final userData = snapshot.data?['user'] ?? {};
          final stats = snapshot.data?['stats'] ?? {};
          final heatmapData = snapshot.data?['heatmap'] ?? <DailyActivity>[];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              children: [
                // Header (Name, Category, Institution from 'profile')
                ProfileHeader(
                  name: userData['full_name'] ?? "User",
                  category: userData['category'] ?? "N/A",
                  institution: userData['institution'] ?? "N/A",
                ),
                const SizedBox(height: 25),

                /// REFINED PROGRESS SECTION
                /// Uses 'user_profile_full' for Easy, Medium, Hard breakdown
                _buildProgressOverview(stats),

                const SizedBox(height: 20),
                
                // Stats Grid (Points, Solved from 'user_profile_full'; Rating from 'profile')
                StatGrid(
                  points: (stats['total_points'] ?? 0).toString(),
                  solved: (stats['total_solved'] ?? 0).toString(),
                  rank: (userData['rating'] ?? 0).toString(),
                ),
                
                const SizedBox(height: 20),
                PersonalDetailsCard(
                  data: userData,
                  onEdit: () => setState(() {}),
                ),
                const SizedBox(height: 20),
                SubmissionHeatmap(activities: heatmapData),
                const SizedBox(height: 20),
                _buildHistoryTile(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Updated layout to fix the named parameter errors
  Widget _buildProgressOverview(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          // 1. Progress Ring Section - Now correctly passing easy, medium, hard
          Expanded(
            flex: 2,
            child: ProgressRing(
              easy: stats['easy_solved'] ?? 0,
              medium: stats['medium_solved'] ?? 0,
              hard: stats['hard_solved'] ?? 0,
            ),
          ),
          
          // Vertical Divider
          Container(height: 80, width: 1, color: Colors.grey.withOpacity(0.2)),
          
          // 2. Breakdown Labels
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SOLVED BY LEVEL", 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey, 
                    letterSpacing: 1.2
                  )
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _miniMetric("Easy", stats['easy_solved'], Colors.green),
                    _miniMetric("Med", stats['medium_solved'], Colors.orange),
                    _miniMetric("Hard", stats['hard_solved'], Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, dynamic count, Color color) {
    return Column(
      children: [
        Text(
          "${count ?? 0}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const SubmissionHistoryPage())
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD), 
          child: Icon(Icons.history, color: Colors.blue)
        ),
        title: const Text("Submission History", style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}