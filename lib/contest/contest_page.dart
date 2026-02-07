import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Import for Timer

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
  late Timer _timer; // Timer to check for time periodically

  @override
  void initState() {
    super.initState();
    fetchContests();

    // Start a periodic timer to refresh the contest status every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        // Refresh the contest list every 10 seconds
        // This will check if any contest has finished and update its status
        separateContestsByStatus();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when the page is disposed
    super.dispose();
  }

  // Fetch contests from Supabase
  Future<void> fetchContests() async {
    try {
      final response = await supabase
          .from('contests')
          .select('*'); // Ensure the table is called 'contests'

      setState(() {
        contests = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        separateContestsByStatus();  // Separate contests into upcoming and completed
      });
    } catch (e) {
      print('Error fetching contests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Separate contests into upcoming and completed
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
        contestEndTime = DateTime.now();  // Default to current time if parsing fails
      }

      final isCompleted = DateTime.now().isAfter(contestEndTime);
      final contestStartTime = DateTime.parse('$date $time');
      final isRunning = DateTime.now().isAfter(contestStartTime);

      if (isCompleted) {
        completedContests.add(contest);  // Add to completed contests
      } else {
        upcomingContests.add(contest);  // Add to upcoming contests
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2, // Two tabs: Upcoming and Completed
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: TabBar(
                tabs: [
                  Tab(
                    text: 'Upcoming',
                  ),
                  Tab(
                    text: 'Completed',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Upcoming Contests Tab
                  UpcomingContestsTab(
                    isLoading: isLoading,
                    contests: upcomingContests,  // Pass upcoming contests here
                  ),
                  // Completed Contests Tab
                  CompletedContestsTab(
                    contests: completedContests,  // Pass completed contests here
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

  const UpcomingContestsTab({
    Key? key,
    required this.isLoading,
    required this.contests,
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
          contestEndTime = DateTime.now();  // Default to current time if parsing fails
        }

        // Real-time checking for contest status
        final isCompleted = DateTime.now().isAfter(contestEndTime);

        final contestStartTime = DateTime.parse('$date $time');
        final isRunning = DateTime.now().isAfter(contestStartTime);

        return GestureDetector(
          onTap: () {
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
            isCompleted: isCompleted,  // Pass isCompleted flag here
          ),
        );
      },
    );
  }
}

class CompletedContestsTab extends StatelessWidget {
  final List<Map<String, dynamic>> contests;

  const CompletedContestsTab({
    Key? key,
    required this.contests,
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
          contestEndTime = DateTime.now();  // Default to current time if parsing fails
        }

        // Real-time checking for contest status
        final isCompleted = DateTime.now().isAfter(contestEndTime);

        final contestStartTime = DateTime.parse('$date $time');
        final isRunning = DateTime.now().isAfter(contestStartTime);

        return GestureDetector(
          onTap: () {
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
            isCompleted: isCompleted,  // Pass isCompleted flag here
          ),
        );
      },
    );
  }
}
