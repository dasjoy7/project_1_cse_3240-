class Problem
{
  final String id;
  final String title;
  final String description;
  final String hint;
  final String difficulty;
  final String category;
  final List<String> tags;
  final int submissionCount;
  final int points;
  final int? userStatus; //1=correct,0=wrong,null=not attempted

  Problem({
    required this.id,
    required this.title,
    required this.description,
    required this.hint,
    required this.difficulty,
    required this.category,
    required this.tags,
    required this.submissionCount,
    required this.points,
    this.userStatus,
  });
  factory Problem.fromMap(Map<String,dynamic>map)
  {
    return Problem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      hint: map['hint'] ?? '',
      difficulty: map['difficulty'],
      category: map['main_category'],
      tags: map['tags']==null?[]: map['tags'].toString().split(','),
      submissionCount: map['submission_count']??0,
      points: map['points'],
      userStatus: map['user_status'],
    );
  }
}