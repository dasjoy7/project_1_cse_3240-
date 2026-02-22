class SubmissionDetail {
  final String problemId;
  final String title;
  final bool isCorrect;
  final DateTime submitDate;

  SubmissionDetail({
    required this.problemId,
    required this.title,
    required this.isCorrect,
    required this.submitDate,
  });

  // Helper to convert Supabase data to our Model
  factory SubmissionDetail.fromMap(Map<String, dynamic> map) {
    return SubmissionDetail(
      problemId: map['problem_id']?.toString() ?? '',
      title: map['title'] ?? 'Unknown Problem',
      isCorrect: map['is_correct'] ?? false,
      submitDate: DateTime.parse(map['submit_date'] ?? DateTime.now().toString()),
    );
  }
}