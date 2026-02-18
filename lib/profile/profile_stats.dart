
import 'package:postgrest/src/types.dart';

class ProfileStats {
  final String userId;
  final String fullName;
  final String username;

  final int totalSubmissions;
  final int accepted;
  final int wrong;
  final int totalSolved;

  final int easySolved;
  final int mediumSolved;
  final int hardSolved;

  ProfileStats({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.totalSubmissions,
    required this.accepted,
    required this.wrong,
    required this.totalSolved,
    required this.easySolved,
    required this.mediumSolved,
    required this.hardSolved,
  });

  factory ProfileStats.fromMap(Map<String,dynamic>map) {
    return ProfileStats(
      userId: map['user_id'],
      fullName: map['full_name'] ?? 'Unknown User',
      username: map['username'] ?? '',
      totalSubmissions: map['total_submissions'] ?? 0,
      accepted: map['accepted'] ?? 0,
      wrong: map['wrong_answer'] ?? 0,
      totalSolved: map['total_solved'] ?? 0,
      easySolved: map['easy_solved'] ?? 0,
      mediumSolved: map['medium_solved'] ?? 0,
      hardSolved: map['hard_solved'] ?? 0,
    );
  }
}