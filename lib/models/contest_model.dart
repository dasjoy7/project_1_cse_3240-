class Contest {
  final String id, title, subtitle, status;
  final DateTime startTime, endTime;
  final String? imageUrl;

  Contest({
    required this.id, required this.title, required this.subtitle, 
    required this.status, required this.startTime, required this.endTime,
    this.imageUrl
  });

  factory Contest.fromMap(Map<String, dynamic> map) {
    return Contest(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'] ?? '',
      status: map['status'] ?? 'upcoming',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      imageUrl: map['image_url'],
    );
  }
}