import 'dart:math';
import 'package:flutter/material.dart';
import 'home_logic.dart';
import 'home_widgets.dart';
import 'package:project_1_cse_3240/problems/screens/problem_detail_page.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Logic for the Floating Action Button to pick a random problem from the list.
  void _navigateToRandomProblem(BuildContext context, List<dynamic> problems) {
    if (problems.isEmpty) return;
    final random = Random();
    final randomProblemMap = problems[random.nextInt(problems.length)];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemDetailPage(
          problem: Problem.fromMap(randomProblemMap),
          title: randomProblemMap['title'] ?? "Random Challenge",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      // We call the logic class we created
      future: HomeLogic.getUserDashboardData(),
      builder: (context, snapshot) {
        // Use guest data while waiting or if an error occurs
        final data = snapshot.data ?? HomeLogic.guestData();

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9), 
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToRandomProblem(context, data['fullProblemList']),
            backgroundColor: const Color(0xFF1E293B), 
            elevation: 4,
            icon: const Icon(Icons.bolt_rounded, color: Colors.amber), 
            label: const Text("RANDOM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          ),
          body: RefreshIndicator(
            // Forces a rebuild of the FutureBuilder to get fresh data
            onRefresh: () async => (context as Element).markNeedsBuild(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(data['name']),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        buildSectionHeader("Performance Stats"),
                        buildStatsCard(data['rating'], data['solved']),
                        
                        const SizedBox(height: 30),
                        buildFeaturedChallenge(context, data['problemMap'], data['problemTitle'], data['problemPoints']),

                        const SizedBox(height: 30),
                        buildSectionHeader("Daily Momentum"),
                        buildStreakSection(data['streak']),

                        const SizedBox(height: 30),
                        buildSectionHeader("Submission Analysis"),
                        buildPerformanceSection(
                          data['total_submissions'], 
                          data['accepted'], 
                          data['wrong']
                        ),

                        const SizedBox(height: 30),
                        buildSectionHeader("Achievement Badges"),
                        buildBadgesSection(),
                        
                        const SizedBox(height: 120), // Padding so FAB doesn't cover content
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}