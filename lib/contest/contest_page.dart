import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'contest_card.dart';
import 'contest_questions_page.dart';
import 'contest_leaderboard_page.dart';

class ContestPage extends StatefulWidget {
  const ContestPage({super.key});

  @override
  _ContestPageState createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> contests = [];
  List<Map<String, dynamic>> upcomingContests = [];
  List<Map<String, dynamic>> completedContests = [];

  Map<String, bool> registrationStatus = {};

  bool isLoading = true;
  late Timer _timer;
  late String userCategory;

  @override
  void initState() {
    super.initState();
    fetchContests();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() => separateContestsByStatus());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchContests() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final userResponse = await supabase
          .from('profile')
          .select('category')
          .eq('id', currentUser.id)
          .single();
      
      userCategory = userResponse['category'] ?? '';

      final response = await supabase.from('contests').select('*');

      final regs = await supabase
          .from('contest_registrations')
          .select('contest_id')
          .eq('user_id', currentUser.id);

      final regSet = {
        for (var r in (regs as List)) r['contest_id'].toString()
      };

      setState(() {
        contests = List<Map<String, dynamic>>.from(response);

        registrationStatus = {for (var c in contests) c['id'].toString(): regSet.contains(c['id'].toString())};
        isLoading = false;

        separateContestsByStatus();
      });

    } catch (e) {
      print('Error fetching contests: $e');
      setState(() => isLoading = false);
    }
  }

  void separateContestsByStatus() {
    upcomingContests = [];
    completedContests = [];

    for (var contest in contests) {
      final date = contest['date'] ?? '';
      final endTime = contest['end_time'] ?? '';
      final time = contest['start_time'] ?? '';

      DateTime contestEndTime;
      
      try {
        contestEndTime = DateTime.parse('$date $endTime');
      } catch (e) {
        contestEndTime = DateTime.now();
      }

      final isCompleted = DateTime.now().isAfter(contestEndTime);

      if (contest['category'] == userCategory) {
        if (isCompleted) {
          completedContests.add(contest);
        } else {
          upcomingContests.add(contest);
        }
      }
    }
  }

  Future<void> _registerForContest(String contestId) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await supabase.from('contest_registrations').upsert({
        'user_id': currentUser.id,
        'contest_id': int.parse(contestId),
      }, onConflict: 'user_id,contest_id');

      final existing = await supabase
          .from('contest_question_submission')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('contest_id', contestId)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('contest_question_submission').insert({
          'user_id': currentUser.id,
          'contest_id': int.parse(contestId),
          'serial_1': null, 'serial_2': null, 'serial_3': null, 'serial_4': null,
          'serial_5': null, 'serial_6': null, 'serial_7': null, 'serial_8': null,
          'serial_1_attempts': 0, 'serial_2_attempts': 0, 'serial_3_attempts': 0,
          'serial_4_attempts': 0, 'serial_5_attempts': 0, 'serial_6_attempts': 0,
          'serial_7_attempts': 0, 'serial_8_attempts': 0,
          'rating': 0,
        });
      }

      setState(() => registrationStatus[contestId] = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registered successfully!'),
            backgroundColor: const Color(0xFF3DAA6E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error registering: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: const Color(0xFFE05555),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _registerUserForContest(String contestId) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;
    try {
      final existing = await supabase
          .from('contest_question_submission')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('contest_id', contestId)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('contest_question_submission').insert({
          'user_id': currentUser.id,
          'contest_id': int.parse(contestId),
          'serial_1': null, 'serial_2': null, 'serial_3': null, 'serial_4': null,
          'serial_5': null, 'serial_6': null, 'serial_7': null, 'serial_8': null,
          'serial_1_attempts': 0, 'serial_2_attempts': 0, 'serial_3_attempts': 0,
          'serial_4_attempts': 0, 'serial_5_attempts': 0, 'serial_6_attempts': 0,
          'serial_7_attempts': 0, 'serial_8_attempts': 0,
          'rating': 0,
        });
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEAEFF6)),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: const Color(0xFF4A90D9),
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90D9).withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF8FA0B4),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        padding: const EdgeInsets.all(3),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upcoming_outlined, size: 15),
                                SizedBox(width: 6),
                                Text('Upcoming'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 15),
                                SizedBox(width: 6),
                                Text('Completed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A90D9),
                        strokeWidth: 2.5,
                      ),
                    )
                  : TabBarView(
                      children: [
                        _UpcomingTab(
                          contests: upcomingContests,
                          registrationStatus: registrationStatus,
                          onRegister: _registerForContest,
                          onNavigate: _registerUserForContest,
                        ),
                        _CompletedTab(
                          contests: completedContests,
                          onNavigate: _registerUserForContest,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class _UpcomingTab extends StatelessWidget {

  final List<Map<String, dynamic>> contests;
  final Map<String, bool> registrationStatus;
  final Future<void> Function(String) onRegister;
  final Future<void> Function(String) onNavigate;

  const _UpcomingTab({
    required this.contests,
    required this.registrationStatus,
    required this.onRegister,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.upcoming_outlined,
                size: 48,
                color: const Color(0xFF4A90D9).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No upcoming contests',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A6A7E),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: contests.length,
      itemBuilder: (context, index) {
        final contest = contests[index];
        final date = contest['date'] ?? '';
        final time = contest['start_time'] ?? '';
        final endTime = contest['end_time'] ?? '';
        final contestTitle = contest['title'] ?? 'No Title';
        final contestSubtitle = contest['description'] ?? 'No Description';
        final contestId = contest['id'].toString();

        DateTime contestEndTime;

        try {
          contestEndTime = DateTime.parse('$date $endTime');
        } catch (e) {
          contestEndTime = DateTime.now();
        }

        final contestStartTime = DateTime.parse('$date $time');
        final isCompleted = DateTime.now().isAfter(contestEndTime);
        final isRunning = DateTime.now().isAfter(contestStartTime);
        final isRegistered = registrationStatus[contestId] ?? false;

        return GestureDetector(
          onTap: () async {
            if (!isRunning && !isCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Contest has not started yet.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              return;
            }
            await onNavigate(contestId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContestQuestionsPage(
                  contestId: contestId,
                  contestTitle: contestTitle,
                  contestSubtitle: contestSubtitle,
                  contestStartTime: contestStartTime,
                  contestEndTime: contestEndTime,
                ),
              ),
            );
          },
          child: ContestCard(
            title: contestTitle,
            description: contestSubtitle,
            date: date,
            time: time,
            endTime: endTime,
            category: contest['category'] ?? 'No Category',
            duration: contest['duration'] ?? 'No Duration',
            isRegistered: isRegistered,
            onRegisterTap: isRegistered ? null : () => onRegister(contestId),
          ),
        );
      },
    );
  }
}


class _CompletedTab extends StatelessWidget {

  final List<Map<String, dynamic>> contests;
  final Future<void> Function(String) onNavigate;

  const _CompletedTab({required this.contests, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3DAA6E).withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: const Color(0xFF3DAA6E).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No completed contests',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A6A7E),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: contests.length,
      itemBuilder: (context, index) {
        final contest = contests[index];
        final contestId = contest['id'].toString();
        final contestTitle = contest['title'] ?? 'No Title';
        final contestSubtitle = contest['description'] ?? 'No Description';
        final contestDate = contest['date'] ?? '';
        final contestTime = contest['start_time'] ?? '';
        final contestEndTime = contest['end_time'] ?? '';

        DateTime contestStartTime;
        DateTime contestEndTimeParsed;

        try {
          contestStartTime = DateTime.parse('$contestDate $contestTime');
          contestEndTimeParsed = DateTime.parse('$contestDate $contestEndTime');
        }
        catch (e) {
          contestStartTime = DateTime.now();
          contestEndTimeParsed = DateTime.now();
        }

        final isCompleted = DateTime.now().isAfter(contestEndTimeParsed);
        final isRunning = DateTime.now().isAfter(contestStartTime);

        return GestureDetector(
          onTap: () async {
            await onNavigate(contestId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContestQuestionsPage(
                  contestId: contestId,
                  contestTitle: contestTitle,
                  contestSubtitle: contestSubtitle,
                  contestStartTime: contestStartTime,
                  contestEndTime: contestEndTimeParsed,
                ),
              ),
            );
          },
          child: ContestCard(
            title: contestTitle,
            description: contestSubtitle,
            date: contestDate,
            time: contestTime,
            endTime: contestEndTime,
            category: contest['category'] ?? 'No Category',
            duration: contest['duration'] ?? 'No Duration',
            onAnalysisTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContestLeaderboardPage(
                    contestId: contestId,
                    contestTitle: contestTitle,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}