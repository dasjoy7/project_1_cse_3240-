import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_activity.dart';
import '../models/submission_detail.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;
  String get _userId => _supabase.auth.currentUser!.id;

  // 1. Fetch from 'profile' table
  Future<Map<String, dynamic>> getRealUserData() async {
    return await _supabase
        .from('profile')
        .select()
        .eq('id', _userId)
        .single();
  }

  // 2. Fetch from 'user_profile_full' table
  Future<Map<String, dynamic>> fetchUserStats() async {
    return await _supabase
        .from('user_profile_full')
        .select()
        .eq('user_id', _userId)
        .single();
  }

  // 3. Fetch from 'user_submission_details' table
  Future<List<SubmissionDetail>> fetchRealSubmissions() async {
    final response = await _supabase
        .from('user_submission_details')
        .select()
        .eq('user_id', _userId)
        .order('submit_date', ascending: false);
    
    return (response as List).map((s) => SubmissionDetail.fromMap(s)).toList();
  }

  // 4. Heatmap logic using 'user_submission_details'
  Future<List<DailyActivity>> fetchHeatmapData() async {
    final response = await _supabase
        .from('user_submission_details')
        .select('submit_date')
        .eq('user_id', _userId);

    final Map<DateTime, int> counts = {};
    for (var row in response) {
      final date = DateTime.parse(row['submit_date']).toLocal();
      final day = DateTime(date.year, date.month, date.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts.entries.map((e) => DailyActivity(date: e.key, count: e.value)).toList();
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    await _supabase.from('profile').update(updates).eq('id', _userId);
  }
}