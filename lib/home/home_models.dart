class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final int studentClass;
  final String category;
  final String division;
  final String district;
  final String institution;
  final int rating;
  final int totalSubmissions;
  final int accepted;
  final int wrong;
  final int easySolve;
  final int mediumSolve;
  final int hardSolve;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.studentClass,
    required this.category,
    required this.division,
    required this.district,
    required this.institution,
    required this.rating,
    required this.totalSubmissions,
    required this.accepted,
    required this.wrong,
    required this.easySolve,
    required this.mediumSolve,
    required this.hardSolve,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id: m['id'],
    fullName: m['full_name'] ?? '',
    username: m['username'] ?? '',
    email: m['email'] ?? '',
    studentClass: m['student_class'] ?? 0,
    category: m['category'] ?? '',
    division: m['division'] ?? '',
    district: m['district'] ?? '',
    institution: m['institution'] ?? '',
    rating: m['rating'] ?? 0,
    totalSubmissions: m['total_submissions'] ?? 0,
    accepted: m['accepted'] ?? 0,
    wrong: m['wrong'] ?? 0,
    easySolve: m['easy_solve'] ?? 0,
    mediumSolve: m['medium_solve'] ?? 0,
    hardSolve: m['hard_solve'] ?? 0,
  );
}

class RankInfo {
  final int countryRank;
  final int divisionRank;
  final int districtRank;

  RankInfo({
    required this.countryRank,
    required this.divisionRank,
    required this.districtRank,
  });
}

class BadgeInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int requiredRating;
  final bool unlocked;

  BadgeInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.requiredRating,
    required this.unlocked,
  });
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final List<DateTime> activeDays; // days with at least 1 submission

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
  });
}

// Static friends list (placeholder)
class Friend {
  final String id;
  final String username;
  final String category;
  final int rating;

  const Friend({
    required this.id,
    required this.username,
    required this.category,
    required this.rating,
  });
}