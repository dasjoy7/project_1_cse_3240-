class SubmissionDetail {
  final String problemId;
  final String title;
  final bool isCorrect;
  SubmissionDetail({
    required this.problemId,
    required this.title,
    required this.isCorrect,
  });
  factory SubmissionDetail.fromMap(Map<String,dynamic>map)
  {
    return SubmissionDetail(
      problemId: map['problem_id'],
      title: map['title'],
      isCorrect: map['is_correct'],
    );
  }
}