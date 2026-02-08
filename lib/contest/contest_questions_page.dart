import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async'; // Import Timer
import 'full_question_page.dart'; // Import the full question page

class ContestQuestionsPage extends StatefulWidget {
  final String contestId;
  final String contestTitle;
  final String contestSubtitle;
  final DateTime contestStartTime; // Contest start time
  final DateTime contestEndTime; // Contest end time

  const ContestQuestionsPage({
    Key? key,
    required this.contestId,
    required this.contestTitle,
    required this.contestSubtitle,
    required this.contestStartTime,
    required this.contestEndTime,
  }) : super(key: key);

  @override
  _ContestQuestionsPageState createState() => _ContestQuestionsPageState();
}

class _ContestQuestionsPageState extends State<ContestQuestionsPage> {
  List<Map<String, dynamic>> questions = []; // Store the questions
  late Timer _timer; // Timer to update countdown
  late Duration _remainingTime; // Remaining time until contest end
  bool _isContestStarted = false; // Flag to track if contest has started
  bool _isContestCompleted = false; // Flag to track if contest has completed

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startCountdown(); // Start the countdown timer when the page is initialized
  }

  // Load questions for the contest from Supabase
  Future<void> _loadQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('contest_id', widget.contestId); // Fetch questions by contest ID

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  // Start the countdown timer
  void _startCountdown() {
    _remainingTime = widget.contestStartTime.difference(DateTime.now());

    // If contest has already started, set _remainingTime to 0
    if (_remainingTime.isNegative) {
      setState(() {
        _remainingTime = Duration(seconds: 0);
        _isContestStarted = true;
      });
    }

    // Start a periodic timer to update every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _updateRemainingTime();
      });

      // If time is up, cancel the timer
      if (_remainingTime.inSeconds <= 0) {
        _timer.cancel();
        setState(() {
          _isContestCompleted = true; // Contest has completed
        });
      }
    });
  }

  // Update the remaining time
  void _updateRemainingTime() {
    DateTime now = DateTime.now();

    // Check if contest has started
    if (now.isAfter(widget.contestStartTime) && !_isContestStarted) {
      _isContestStarted = true;
    }

    // Calculate remaining time until contest end
    _remainingTime = widget.contestEndTime.difference(now);

    // Ensure remaining time doesn't go negative
    if (_remainingTime.isNegative) {
      _remainingTime = Duration(seconds: 0);
      _isContestCompleted = true; // Contest has completed
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Format the remaining time as hours, minutes, and seconds
  String _formatTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contestTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contest title and subtitle
            Text(
              widget.contestSubtitle,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Timer section - Countdown of remaining time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 5 ? Colors.red.shade50 : Colors.blue.shade50,
                border: Border.all(
                  color: _remainingTime.inMinutes < 5 ? Colors.red : Colors.blue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _isContestStarted ? 'Time Remaining' : 'Starts In',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formatTime(_remainingTime),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _remainingTime.inMinutes < 5 ? Colors.red : Colors.blue,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Display list of questions
            Text(
              'Questions: ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Display list of questions
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final questionName = question['name'] ?? 'No Name'; // Safe fallback
                  final questionText = question['question_text'] ?? 'No Text'; // Safe fallback

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text('${question['serial_number']}. $questionName'),
                      subtitle: Text(questionText),
                      onTap: () {
                        if (!_isContestCompleted) {
                          // Navigate to the full question page if contest is started and not completed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullQuestionPage(
                                questionId: question['id'].toString(),
                              ),
                            ),
                          );
                        } else {
                          // If the contest has completed, show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Contest has been completed, submission is closed.")),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
