import 'package:supabase_flutter/supabase_flutter.dart';
import '../problems/model/submission_detail.dart';
import 'profile_stats.dart';
import 'profile_daily_submission.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  // =========================
  // PROFILE STATS
  // =========================
  Future<ProfileStats>fetchProfileStats()async{
    final user=_client.auth.currentUser;
    if(user==null) throw Exception("Not logged in");
    final res = await _client
        .from('user_profile_stats')
        .select()
        .eq('user_id',user.id)
        .single();
    return ProfileStats.fromMap(res);
  }

  // =========================
  // DAILY SUBMISSIONS
  // =========================
  Future<List<DailySubmission>> fetchDailySubmissions() async {
    final user=_client.auth.currentUser;
    if (user==null) throw Exception("Not logged in");
    final response=await _client
        .from('user_daily_submissions')
        .select()
        .eq('user_id',user.id)
        .order('submit_date',ascending:false);

    return (response as List)
        .map((e)=>DailySubmission.fromMap(e))
        .toList();
  }

  // =========================
  // SUBMISSION DETAILS BY DATE
  // =========================
  Future<List<SubmissionDetail>>fetchSubmissionDetails(DateTime date)async{
    final user=_client.auth.currentUser;
    if (user==null) throw Exception("Not logged in");
    final formattedDate=date.toIso8601String().split('T').first;
    final response=await _client
        .from('user_submission_details')
        .select()
        .eq('user_id',user.id)
        .eq('submit_date',formattedDate);

    return(response as List)
        .map((e)=>SubmissionDetail.fromMap(e))
        .toList();
  }
}