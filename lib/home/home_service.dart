import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_models.dart';

class HomeService {
  static final _client = Supabase.instance.client;
  static String get _userId => _client.auth.currentUser!.id;

  // ─────────────────────────────────────
  // Profile
  // ─────────────────────────────────────
  static Future<UserProfile> fetchProfile() async {
    final data = await _client
        .from('profile')
        .select()
        .eq('id', _userId)
        .single();
    return UserProfile.fromMap(data);
  }

  // ─────────────────────────────────────
  // Total contests participated
  // ─────────────────────────────────────
  static Future<int> fetchTotalContests() async {
    final rows = await _client
        .from('contest_registrations')
        .select('id')
        .eq('user_id', _userId);
    return (rows as List).length;
  }

  // ─────────────────────────────────────
  // Friends
  // ─────────────────────────────────────
  static Future<List<Friend>> fetchFriends() async {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser!.id;

    final friendships = await client
        .from('friendships')
        .select()
        .eq('status', 'accepted')
        .or('requester_id.eq.$currentUserId,receiver_id.eq.$currentUserId');

    final friendIds = friendships.map<String>((f) {
      return f['requester_id'] == currentUserId
          ? f['receiver_id'] as String
          : f['requester_id'] as String;
    }).toList();

    if (friendIds.isEmpty) return [];

    final profiles = await client
        .from('profile')
        .select()
        .inFilter('id', friendIds);

    return profiles.map<Friend>((p) => Friend(
      id: p['id'] ?? '',
      username: p['username'] ?? '',
      category: p['category'] ?? '',
      rating: p['rating'] ?? 0,
    )).toList();
  }

  // ─────────────────────────────────────
  // Rankings (within same category)
  // ─────────────────────────────────────
  static Future<RankInfo> fetchRanks(UserProfile profile) async {
    final countryData = await _client
        .from('profile')
        .select('id, rating')
        .eq('category', profile.category)
        .order('rating', ascending: false);

    final divisionData = await _client
        .from('profile')
        .select('id, rating')
        .eq('category', profile.category)
        .eq('division', profile.division)
        .order('rating', ascending: false);

    final districtData = await _client
        .from('profile')
        .select('id, rating')
        .eq('category', profile.category)
        .eq('district', profile.district)
        .order('rating', ascending: false);

    int findRank(List rows) {
      for (int i = 0; i < rows.length; i++) {
        if (rows[i]['id'] == _userId) return i + 1;
      }
      return rows.length + 1;
    }

    return RankInfo(
      countryRank: findRank(countryData as List),
      divisionRank: findRank(divisionData as List),
      districtRank: findRank(districtData as List),
    );
  }

  // ─────────────────────────────────────
  // Streak
  // ─────────────────────────────────────
  static Future<StreakInfo> fetchStreak() async {
    final data = await _client
        .from('submissions')
        .select('submitted_at')
        .eq('user_id', _userId)
        .order('submitted_at', ascending: false);

    final rows = data as List;

    final Set<String> uniqueDays = {};
    for (final row in rows) {
      final dt = DateTime.parse(row['submitted_at']).toLocal();
      uniqueDays.add('${dt.year}-${dt.month}-${dt.day}');
    }

    final activeDays = uniqueDays.map((s) {
      final parts = s.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()
      ..sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    DateTime check = DateTime.now();
    check = DateTime(check.year, check.month, check.day);

    for (int i = 0; i < 365; i++) {
      final day = check.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      if (uniqueDays.contains(key)) {
        currentStreak++;
      } else {
        if (i == 0) continue;
        break;
      }
    }

    int longestStreak = 0;
    int tempStreak = 0;
    for (int i = 0; i < activeDays.length; i++) {
      if (i == 0) {
        tempStreak = 1;
      } else {
        final diff = activeDays[i - 1].difference(activeDays[i]).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      activeDays: activeDays,
    );
  }

  // ─────────────────────────────────────
  // Badges
  // ─────────────────────────────────────
  static List<BadgeInfo> getBadges(int rating) {
    return [
      BadgeInfo(id: 'b1', name: 'Newcomer',   emoji: '🌱', description: 'Just getting started', requiredRating: 0,    unlocked: rating >= 0),
      BadgeInfo(id: 'b2', name: 'Apprentice', emoji: '⚡', description: 'Reach 100 rating',      requiredRating: 100,  unlocked: rating >= 100),
      BadgeInfo(id: 'b3', name: 'Scholar',    emoji: '📚', description: 'Reach 250 rating',      requiredRating: 250,  unlocked: rating >= 250),
      BadgeInfo(id: 'b4', name: 'Challenger', emoji: '🔥', description: 'Reach 500 rating',      requiredRating: 500,  unlocked: rating >= 500),
      BadgeInfo(id: 'b5', name: 'Expert',     emoji: '🏆', description: 'Reach 1000 rating',     requiredRating: 1000, unlocked: rating >= 1000),
      BadgeInfo(id: 'b6', name: 'Master',     emoji: '💎', description: 'Reach 2000 rating',     requiredRating: 2000, unlocked: rating >= 2000),
      BadgeInfo(id: 'b7', name: 'Legend',     emoji: '👑', description: 'Reach 5000 rating',     requiredRating: 5000, unlocked: rating >= 5000),
    ];
  }
}