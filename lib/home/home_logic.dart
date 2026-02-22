import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// This class encapsulates all the data fetching and business logic for the Home Page.
/// Separating this makes the UI code cleaner and easier to test.
class HomeLogic {
  
  /// Fetches all necessary dashboard data from Supabase.
  /// We combine multiple queries into one Future to use with FutureBuilder.
  static Future<Map<String, dynamic>> getUserDashboardData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      // Return guest defaults if no user is logged in
      if (user == null) return guestData();

      // 1. Fetch performance stats (Total solved, accepted, etc.)
      final statsData = await Supabase.instance.client
          .from('user_profile_full')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      // 2. Fetch rating from the profile table
      final profileData = await Supabase.instance.client
          .from('profile')
          .select('rating')
          .eq('id', user.id)
          .maybeSingle();

      // 3. Fetch submission history to calculate the streak
      final streakData = await Supabase.instance.client
          .from('user_daily_submissions')
          .select('submit_date')
          .eq('user_id', user.id)
          .order('submit_date', ascending: false);

      int currentStreak = calculateStreak(streakData);

      // 4. Fetch all problems to select the "Problem of the Day" and for the Random FAB
      final List<dynamic> problemList = await Supabase.instance.client
          .from('problems')
          .select('*');

      Map<String, dynamic> dailyProblemMap = {};

      // Logic to pick a "Problem of the Day" based on the current calendar day
      if (problemList.isNotEmpty) {
        int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        int index = dayOfYear % problemList.length;
        dailyProblemMap = problemList[index];
      }

      return {
        "name": statsData?['full_name'] ?? "Math Athlete",
        "rating": profileData?['rating']?.toString() ?? "0",
        "solved": statsData?['total_solved']?.toString() ?? "0",
        "total_submissions": statsData?['total_submission']?.toString() ?? "0", 
        "accepted": statsData?['accepted']?.toString() ?? "0",
        "wrong": statsData?['wrong_answer']?.toString() ?? "0",
        "problemMap": dailyProblemMap, 
        "fullProblemList": problemList,
        "problemTitle": dailyProblemMap['title'] ?? "Daily Challenge",
        "problemPoints": dailyProblemMap['points']?.toString() ?? "0",
        "streak": currentStreak.toString(),
      };
    } catch (e) {
      debugPrint("Dashboard Fetch Error: $e");
      return guestData();
    }
  }

  /// Calculates consecutive days of activity.
  /// If the gap between today and the last submission is > 1 day, streak resets.
  static int calculateStreak(List<dynamic> data) {
    if (data.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime lastDate = DateTime.parse(data[0]['submit_date']);
    
    // If the most recent submission wasn't today or yesterday, streak is 0
    if (today.difference(lastDate).inDays > 1) return 0;
    
    DateTime compareDate = lastDate;
    for (var entry in data) {
      DateTime entryDate = DateTime.parse(entry['submit_date']);
      if (compareDate.difference(entryDate).inDays <= 1) {
        streak++;
        compareDate = entryDate;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Default values used for guests or when a network error occurs.
  static Map<String, dynamic> guestData() {
    return {
      "name": "Math Athlete",
      "rating": "0",
      "solved": "0",
      "total_submissions": "0",
      "accepted": "0",
      "wrong": "0",
      "problemMap": {},
      "fullProblemList": [],
      "problemTitle": "Loading...",
      "problemPoints": "0",
      "streak": "0",
    };
  }
}