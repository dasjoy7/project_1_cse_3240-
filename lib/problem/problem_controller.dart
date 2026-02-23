import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'problem_model.dart';

class ProblemController extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<ProblemModel> _problems = [];
  bool _isLoading = false;
  String? _error;

  // Filter state
  String? selectedDifficulty;
  String? selectedSubCategory;

  List<ProblemModel> get problems => _problems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasActiveFilter => selectedDifficulty != null || selectedSubCategory != null;

  String? get _userId => _client.auth.currentUser?.id;

  List<String> subCategoriesFor(String mainCategory) {
    return _problems
        .where((p) => p.mainCategory == mainCategory)
        .map((p) => p.subCategory)
        .toSet()
        .toList()
      ..sort();
  }

  void setDifficulty(String? difficulty) {
    selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setSubCategory(String? subCategory) {
    selectedSubCategory = subCategory;
    notifyListeners();
  }

  void clearFilters() {
    selectedDifficulty = null;
    selectedSubCategory = null;
    notifyListeners();
  }

  List<ProblemModel> byCategory(String category) {
    return _problems.where((p) {
      if (p.mainCategory != category) return false;
      if (selectedDifficulty != null &&
          p.difficulty.toLowerCase() != selectedDifficulty!.toLowerCase()) return false;
      if (selectedSubCategory != null && p.subCategory != selectedSubCategory) return false;
      return true;
    }).toList();
  }

  Future<void> fetchProblems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final problemsData = await _client.from('problems').select().order('created_at');
      _problems = (problemsData as List).map((e) => ProblemModel.fromMap(e)).toList();

      if (_userId != null) {
        await _markUserProgress();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _markUserProgress() async {
    if (_userId == null) return;
    final subs = await _client
        .from('submissions')
        .select('problem_id, is_correct')
        .eq('user_id', _userId!);

    final Map<String, bool> progressMap = {};
    for (final sub in subs as List) {
      final pid = sub['problem_id'] as String;
      final correct = sub['is_correct'] as bool;
      if (correct) {
        progressMap[pid] = true;
      } else {
        progressMap.putIfAbsent(pid, () => false);
      }
    }

    for (final p in _problems) {
      p.userSolvedCorrectly = progressMap[p.id];
    }
  }

  Future<SubmissionResult> submitAnswer({
    required String problemId,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    if (_userId == null) return SubmissionResult.failed;

    final isCorrect =
        userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

    try {
      final problem = _problems.firstWhere((p) => p.id == problemId);
      final difficulty = problem.difficulty.toLowerCase();
      final wasAlreadySolvedCorrectly = problem.userSolvedCorrectly == true;

      // 1. Store submission — trigger auto-increments total_submission on problems table
      await _client.from('submissions').insert({
        'user_id': _userId,
        'problem_id': problemId,
        'is_correct': isCorrect,
      });

      // 2. Fetch updated total_submission to sync local card
      final current = await _client
          .from('problems')
          .select('total_submission')
          .eq('id', problemId)
          .single();
      problem.totalSubmission = (current['total_submission'] ?? 0) as int;

      // 5. Update profile stats
      await _updateProfileStats(
        isCorrect: isCorrect,
        difficulty: difficulty,
        wasAlreadySolvedCorrectly: wasAlreadySolvedCorrectly,
      );

      // 6. Update solved status locally
      if (isCorrect) {
        problem.userSolvedCorrectly = true;
      } else {
        problem.userSolvedCorrectly ??= false;
      }

      notifyListeners();

      return isCorrect ? SubmissionResult.correct : SubmissionResult.wrong;
    } catch (e) {
      debugPrint('submitAnswer error: $e');
      return SubmissionResult.failed;
    }
  }

  Future<void> _updateProfileStats({
    required bool isCorrect,
    required String difficulty,
    required bool wasAlreadySolvedCorrectly,
  }) async {
    if (_userId == null) return;

    final profileData = await _client
        .from('profile')
        .select(
        'total_submissions, accepted, wrong, easy_solve, medium_solve, hard_solve')
        .eq('id', _userId!)
        .single();

    int totalSubmissions = (profileData['total_submissions'] ?? 0) + 1;
    int accepted = profileData['accepted'] ?? 0;
    int wrong = profileData['wrong'] ?? 0;
    int easySolve = profileData['easy_solve'] ?? 0;
    int mediumSolve = profileData['medium_solve'] ?? 0;
    int hardSolve = profileData['hard_solve'] ?? 0;

    if (isCorrect) {
      accepted += 1;
      if (!wasAlreadySolvedCorrectly) {
        switch (difficulty) {
          case 'easy':
            easySolve += 1;
            break;
          case 'medium':
            mediumSolve += 1;
            break;
          case 'hard':
            hardSolve += 1;
            break;
        }
      }
    } else {
      wrong += 1;
    }

    await _client.from('profile').update({
      'total_submissions': totalSubmissions,
      'accepted': accepted,
      'wrong': wrong,
      'easy_solve': easySolve,
      'medium_solve': mediumSolve,
      'hard_solve': hardSolve,
    }).eq('id', _userId!);
  }

  Future<List<SubmissionModel>> getSubmissionHistory(String problemId) async {
    if (_userId == null) return [];
    final data = await _client
        .from('submissions')
        .select()
        .eq('user_id', _userId!)
        .eq('problem_id', problemId)
        .order('submitted_at', ascending: false);
    return (data as List).map((e) => SubmissionModel.fromMap(e)).toList();
  }
}

enum SubmissionResult { correct, wrong, failed }