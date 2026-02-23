class ProblemModel {
  final String id;
  final String mainCategory;
  final String subCategory;
  final String difficulty;
  final String title;
  final String description;
  final String? hint;
  final String answer;
  int totalSubmission;
  bool? userSolvedCorrectly; // null = never attempted

  ProblemModel({
    required this.id,
    required this.mainCategory,
    required this.subCategory,
    required this.difficulty,
    required this.title,
    required this.description,
    this.hint,
    required this.answer,
    required this.totalSubmission,
    this.userSolvedCorrectly,
  });

  factory ProblemModel.fromMap(Map<String, dynamic> map) {
    return ProblemModel(
      id: map['id'],
      mainCategory: map['main_category'],
      subCategory: map['sub_category'],
      difficulty: map['difficulty'],
      title: map['title'],
      description: map['description'],
      hint: map['hint'],
      answer: map['answer'],
      totalSubmission: map['total_submission'] ?? 0,
    );
  }
}

class SubmissionModel {
  final String id;
  final String userId;
  final String problemId;
  final bool isCorrect;
  final DateTime submittedAt;

  SubmissionModel({
    required this.id,
    required this.userId,
    required this.problemId,
    required this.isCorrect,
    required this.submittedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'],
      userId: map['user_id'],
      problemId: map['problem_id'],
      isCorrect: map['is_correct'],
      submittedAt: DateTime.parse(map['submitted_at']),
    );
  }
}