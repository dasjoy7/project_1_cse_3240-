import 'package:flutter/material.dart';
import 'home_models.dart';
import 'home_service.dart';
import 'widgets/rank_card.dart';
import 'widgets/streak_section.dart';
import 'widgets/badges_section.dart';
import 'widgets/performance_graph.dart';
import 'widgets/stats_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserProfile? _profile;
  RankInfo? _ranks;
  StreakInfo? _streak;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await HomeService.fetchProfile();
      final ranks = await HomeService.fetchRanks(profile);
      final streak = await HomeService.fetchStreak();
      if (mounted) {
        setState(() {
          _profile = profile;
          _ranks = ranks;
          _streak = streak;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;
    final badges = HomeService.getBadges(profile.rating);
    final friends = HomeService.getStaticFriends();

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            RankCard(profile: profile, ranks: _ranks),
            if (_streak != null) StreakSection(streak: _streak!),
            BadgesSection(badges: badges),
            PerformanceGraph(profile: profile),
            StatsSection(
              profile: profile,
              friends: friends,
              totalContests: 0,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}