import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'contest_card.dart';  // Import the ContestCard widget
import 'contest_questions_page.dart';

class ContestPage extends StatefulWidget {
  const ContestPage({super.key});

  @override
  _ContestPageState createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> contests = []; // List to hold contest data
  bool isLoading = true;  // Flag to track loading state

  @override
  void initState() {
    super.initState();
    fetchContests();
  }

  // Fetch contests from Supabase
  Future<void> fetchContests() async {
    try {
      final response = await supabase
          .from('contests') // Ensure the table is called 'contests'
          .select('*'); // Select all fields

      setState(() {
        contests = List<Map<String, dynamic>>.from(response);
        isLoading = false;  // Set loading to false after fetching data
      });
    } catch (e) {
      print('Error fetching contests: $e');
      setState(() {
        isLoading = false;  // Set loading to false even if there’s an error
      });
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
                  UpcomingContestsTab(isLoading: isLoading, contests: contests),
                  // Completed Contests Tab
                  CompletedContestsTab(),
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
    // Show loading spinner while fetching data
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show message if no contests are available
    if (contests.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming contests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Display contests if available
    return ListView.builder(
      itemCount: contests.length,
      itemBuilder: (context, index) {
        final contest = contests[index];
        final date = contest['date'] ?? ''; // Fetch the contest date
        final time = contest['start_time'] ?? ''; // Fetch the contest start time
        final endTime = contest['end_time'] ?? ''; // Fetch the contest end time
        final status = contest['status'] ?? 'upcoming'; // Fetch the contest status

        // Ensure no null values are passed to ContestQuestionsPage
        final contestTitle = contest['title'] ?? 'No Title';
        final contestSubtitle = contest['description'] ?? 'No Description';
        final contestId = contest['id']?.toString() ?? 'Unknown';

        // Combine the date and end_time to compare with current time
        DateTime contestEndTime;
        try {
          contestEndTime = DateTime.parse('$date $endTime');
        } catch (e) {
          contestEndTime = DateTime.now();  // Default to current time if parsing fails
        }

        // Check if the contest is completed based on current time
        final isCompleted = DateTime.now().isAfter(contestEndTime);

        try {
          final contestStartTime = DateTime.parse('$date $time'); // Parse date and time
          final isRunning = DateTime.now().isAfter(contestStartTime); // Check if contest is running

          return GestureDetector(
            onTap: () {
              // Check if the contest has started and if it's completed
              if (isCompleted) {
                // Navigate to ContestQuestionsPage when contest is completed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContestQuestionsPage(
                      contestId: contestId,  // Pass the contest id
                      contestTitle: contestTitle,  // Pass the contest title
                      contestSubtitle: contestSubtitle,  // Pass the contest description
                      contestStartTime: contestStartTime,  // Pass the contest start time
                      contestEndTime: contestEndTime,  // Pass the contest end time
                      // isCompleted: true,
                    ),
                  ),
                );
              } else if (isRunning) {
                // Navigate to ContestQuestionsPage when contest is running
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContestQuestionsPage(
                      contestId: contestId,
                      contestTitle: contestTitle,
                      contestSubtitle: contestSubtitle,
                      contestStartTime: contestStartTime,
                      contestEndTime: contestEndTime,
                      // isCompleted: false,
                    ),
                  ),
                );
              } else {
                // Show a message that the contest hasn't started
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contest has not started yet.')),
                );
              }
            },
            child: ContestCard(
              title: contestTitle,
              description: contestSubtitle,
              date: date,  // Pass date field
              time: time,  // Pass time field
              category: contest['category'] ?? 'No Category',
              duration: contest['duration'] ?? 'No Duration',
              isRunning: isRunning,  // Pass running status
            ),
          );
        } catch (e) {
          // If parsing fails, display an error message
          return const Center(
            child: Text(
              'Invalid date/time format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }
}

class CompletedContestsTab extends StatelessWidget {
  const CompletedContestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Completed Contests',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
