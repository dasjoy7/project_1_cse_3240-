import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'contest_card.dart';
import 'contest_questions_page.dart';

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

  bool isLoading = true;

  late Timer _timer;
  late String userCategory;

  @override
  void initState() {
    super.initState();
    fetchContests();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        separateContestsByStatus();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Fetch contests from Supabase
  Future<void> fetchContests() async {
    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        print('User is not authenticated');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final userResponse = await supabase
          .from('profile')
          .select('category')
          .eq('id', currentUser.id)
          .single();

      userCategory = userResponse['category'] ?? ''; //null-aware operator

      // Fetch contests
      final response = await supabase.from('contests').select('*');

      setState(() {
        contests = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        separateContestsByStatus();
      });
    } catch (e) {
      print('Error fetching contests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Separate contests into upcoming and completed based on contest's category
  void separateContestsByStatus() {
    upcomingContests = [];
    completedContests = [];

    for (var contest in contests) {
      final date = contest['date'] ?? '';
      final time = contest['start_time'] ?? '';
      final endTime = contest['end_time'] ?? '';

      DateTime contestEndTime;

      try {
        contestEndTime = DateTime.parse('$date $endTime');
      } catch (e) {
        contestEndTime = DateTime.now();
      }

      final isCompleted = DateTime.now().isAfter(contestEndTime);
      final contestStartTime = DateTime.parse('$date $time');
      final isRunning = DateTime.now().isAfter(contestStartTime);

      if (contest['category'] == userCategory) {
        if (isCompleted) {
          completedContests.add(contest);
        } else {
          upcomingContests.add(contest);
        }
      }
    }
  }

  // Register the user for a contest if not already registered
  Future<void> _registerUserForContest(String contestId) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      print('User is not authenticated');
      return;
    }

    try {
      final userId = currentUser.id;

      // Check if the user is already registered for the contest
      // maybeSingle() returns null if no row found, single() throws if no row found
      final existing = await supabase
          .from('contest_question_submission')
          .select('*')
          .eq('user_id', userId)
          .eq('contest_id', contestId)
          .maybeSingle(); // ✅ returns null if not found, instead of throwing

      if (existing != null) {
        print('User already registered for contest $contestId');
        return;
      }

      // User is not registered, so register them
      await supabase.from('contest_question_submission').insert({
        'user_id': userId,
        'contest_id': contestId,
        'serial_1': null,
        'serial_2': null,
        'serial_3': null,
        'serial_4': null,
        'serial_5': null,
        'serial_6': null,
        'serial_7': null,
        'serial_8': null,
        'rating': 0,
      });

      print('User registered for contest $contestId');
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: TabBar(
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        UpcomingContestsTab(
                          isLoading: isLoading,
                          contests: upcomingContests,
                          registerUser: _registerUserForContest,
                        ),
                        CompletedContestsTab(
                          contests: completedContests,
                          registerUser: _registerUserForContest,
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

class UpcomingContestsTab extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> contests;
  final Future<void> Function(String) registerUser;

  const UpcomingContestsTab({
    Key? key,
    required this.isLoading,
    required this.contests,
    required this.registerUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contests.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming contests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        final contestId = contest['id']?.toString() ?? 'Unknown';

        DateTime contestEndTime;

        try {
          contestEndTime = DateTime.parse('$date $endTime');
        } catch (e) {
          contestEndTime =
              DateTime.now(); // Default to current time if parsing fails
        }

        // Real-time checking for contest status
        final isCompleted = DateTime.now().isAfter(contestEndTime);

        final contestStartTime = DateTime.parse('$date $time');
        final isRunning = DateTime.now().isAfter(contestStartTime);

        return GestureDetector(
          onTap: () async {
            // Register the user for the contest when they click on it
            await registerUser(contestId);

            if (isCompleted) {
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
            } else if (isRunning) {
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contest has not started yet.')),
              );
            }
          },
          child: ContestCard(
            title: contestTitle,
            description: contestSubtitle,
            date: date,
            time: time,
            category: contest['category'] ?? 'No Category',
            duration: contest['duration'] ?? 'No Duration',
            isRunning: isRunning,
            isCompleted: isCompleted, // Pass isCompleted flag here
          ),
        );
      },
    );
  }
}

class CompletedContestsTab extends StatelessWidget {
  final List<Map<String, dynamic>> contests;
  final Future<void> Function(String) registerUser;

  const CompletedContestsTab({
    Key? key,
    required this.contests,
    required this.registerUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) {
      return const Center(
        child: Text(
          'No completed contests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: contests.length,
      itemBuilder: (context, index) {
        final contest = contests[index];
        final contestId = contest['id']?.toString() ?? 'Unknown';
        final contestTitle = contest['title'] ?? 'No Title';
        final contestSubtitle = contest['description'] ?? 'No Description';
        final contestDate = contest['date'] ?? 'No Date';
        final contestTime = contest['start_time'] ?? 'No Time';
        final contestEndTime = contest['end_time'] ?? 'No End Time';
        final contestCategory = contest['category'] ?? 'No Category';
        final contestDuration = contest['duration'] ?? 'No Duration';

        // Parse the start and end time
        DateTime contestStartTime;
        DateTime contestEndTimeParsed;
        try {
          contestStartTime = DateTime.parse('$contestDate $contestTime');
          contestEndTimeParsed = DateTime.parse('$contestDate $contestEndTime');
        } catch (e) {
          contestStartTime = DateTime.now();
          contestEndTimeParsed = DateTime.now(); // Default to current time if parsing fails
        }

        // Determine if the contest is completed or running
        final isCompleted = DateTime.now().isAfter(contestEndTimeParsed);
        final isRunning = DateTime.now().isAfter(contestStartTime);

        return GestureDetector(
          onTap: () async {
            // Register the user for the contest when they click on it
            await registerUser(contestId);

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
            category: contestCategory,
            duration: contestDuration,
            isRunning: isRunning, // Pass isRunning flag here
            isCompleted: isCompleted, // Pass isCompleted flag here
          ),
        );
      },
    );
  }
}

