class DailySubmission {
  final DateTime date;
  final int count;

  DailySubmission({
    required this.date,
    required this.count,
  });
  factory DailySubmission.fromMap(Map<String,dynamic>map) {
    return DailySubmission(
      date:DateTime.parse(map['submit_date']),
      count:map['submissions'],
    );
  }
}
