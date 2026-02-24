import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'problem_model.dart';

class ProblemController extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final ProblemController _instance = ProblemController._internal();
  factory ProblemController() => _instance;
  ProblemController._internal();

  final _client = Supabase.instance.client;

  List<ProblemModel> _problems = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  // Filter state
  String? selectedDifficulty;
  String? selectedSubCategory;

  RealtimeChannel? _realtimeChannel;

  List<ProblemModel> get problems => _problems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasActiveFilter =>
      selectedDifficulty != null || selectedSubCategory != null;

  String? get _userId => _client.auth.currentUser?.id;

  // ── Prevent singleton from being disposed ────────────────────────────────
  @override
  void dispose() {
    debugPrint('⚠️ dispose() called on singleton ProblemController — ignored');
    // Do NOT call super.dispose() — singleton must stay alive
  }

  void forceDispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  // ── Init ─────────────────────────────────────────────────────────────────
  void init() {
    if (_initialized) return;
    _initialized = true;
    debugPrint('✅ ProblemController initialized');
    fetchProblems();
    _subscribeToRealtime();
  }

  // ── Realtime ──────────────────────────────────────────────────────────────
  void _subscribeToRealtime() {
    _realtimeChannel = _client
        .channel('problems_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'problems',
      callback: (payload) {
        debugPrint('🟢 Realtime event: ${payload.eventType}');
        fetchProblems();
      },
    )
        .subscribe();
    debugPrint('🔴 Realtime subscribed');
  }

  // ── Filters ───────────────────────────────────────────────────────────────
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
          p.difficulty.toLowerCase() != selectedDifficulty!.toLowerCase())
        return false;
      if (selectedSubCategory != null && p.subCategory != selectedSubCategory)
        return false;
      return true;
    }).toList();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> fetchProblems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final problemsData =
      await _client.from('problems').select().order('created_at');
      debugPrint('✅ Fetched ${(problemsData as List).length} problems');
      _problems = problemsData.map((e) => ProblemModel.fromMap(e)).toList();

      if (_userId != null) {
        await _markUserProgress();
      }
    } catch (e) {
      debugPrint('❌ fetchProblems error: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── User Progress ─────────────────────────────────────────────────────────
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

  // ── Submit Answer ─────────────────────────────────────────────────────────
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

      await _client.from('submissions').insert({
        'user_id': _userId,
        'problem_id': problemId,
        'is_correct': isCorrect,
      });

      final current = await _client
          .from('problems')
          .select('total_submission')
          .eq('id', problemId)
          .single();
      problem.totalSubmission = (current['total_submission'] ?? 0) as int;

      await _updateProfileStats(
        isCorrect: isCorrect,
        difficulty: difficulty,
        wasAlreadySolvedCorrectly: wasAlreadySolvedCorrectly,
      );

      if (isCorrect) {
        problem.userSolvedCorrectly = true;
      } else {
        problem.userSolvedCorrectly ??= false;
      }

      notifyListeners();

      return isCorrect ? SubmissionResult.correct : SubmissionResult.wrong;
    } catch (e) {
      debugPrint('❌ submitAnswer error: $e');
      return SubmissionResult.failed;
    }
  }

  // ── Profile Stats ─────────────────────────────────────────────────────────
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

  // ── Submission History ────────────────────────────────────────────────────
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