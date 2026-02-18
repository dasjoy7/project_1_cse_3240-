import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_1_cse_3240/problems/model/problem.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Problem>> fetchProblems({
    required String category,
    required String difficulty,
    required String search,
  }) async {
    var query = _client.from('problems_with_counts').select();

    query = query.eq('main_category', category);

    if (difficulty != 'All') {
      query = query.eq('difficulty', difficulty);
    }

    if (search.isNotEmpty) {
      query = query.ilike('title', '%$search%');
    }

    final res = await query;
    return (res as List).map((e) => Problem.fromMap(e)).toList();
  }

  Future<bool> submitAnswer({
    required String problemId,
    required String userAnswer,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final problem = await _client
        .from('problems')
        .select('answer, points')
        .eq('id', problemId)
        .single();

    final isCorrect =
        problem['answer'].toString().trim().toLowerCase() ==
            userAnswer.trim().toLowerCase();

    await _client.from('problem_submissions').upsert({
      'user_id': user.id,
      'problem_id': problemId,
      'is_correct': isCorrect,
    });

    await _client.rpc('update_user_status', params: {
      'uid': user.id,
      'is_correct': isCorrect,
      'points': problem['points'],
    });

    return isCorrect;
  }
}