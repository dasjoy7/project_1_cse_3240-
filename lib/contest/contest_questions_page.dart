import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'full_question_page.dart';

class ContestQuestionsPage extends StatefulWidget {
  final String contestId;
  final String contestTitle;
  final String contestSubtitle;
  final DateTime contestStartTime;
  final DateTime contestEndTime;

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

  List<Map<String, dynamic>> questions = [];
  Map<String, bool?> answerStatus = {}; // Store the correctness of each answer

  late Timer _timer;
  late Duration _remainingTime;

  bool _isContestStarted = false;
  bool _isContestCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startCountdown();
  }

  // Load questions from Supabase
  Future<void> _loadQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('contest_id', widget.contestId);

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        for (var question in questions) {
          answerStatus[question['id'].toString()] =
              null; // Default status for all answers
        }
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  // Start countdown timer
  void _startCountdown() {
    _remainingTime = widget.contestStartTime.difference(DateTime.now());

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

      if (_remainingTime.inSeconds <= 0) {
        _timer.cancel();
        setState(() {
          _isContestCompleted = true;
        });
      }
    });
  }

  void _updateRemainingTime() {
    DateTime now = DateTime.now();
    if (now.isAfter(widget.contestStartTime) && !_isContestStarted) {
      _isContestStarted = true;
    }

    _remainingTime = widget.contestEndTime.difference(now);

    if (_remainingTime.isNegative) {
      _remainingTime = Duration(seconds: 0);
      _isContestCompleted = true;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Format remaining time
  String _formatTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contestTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contestSubtitle, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 5
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                border: Border.all(
                  color: _remainingTime.inMinutes < 5
                      ? Colors.red
                      : Colors.blue,
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
                      color: _remainingTime.inMinutes < 5
                          ? Colors.red
                          : Colors.blue,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Questions: ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final questionName = question['name'] ?? 'No Name';
                  final questionText = question['question_text'] ?? 'No Text';
                  final questionId = question['id'].toString();

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                        '${question['serial_number']}. $questionName',
                      ),
                      subtitle: Text(questionText),
                      trailing: answerStatus[questionId] == true
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ) // Green check for correct
                          : answerStatus[questionId] == false
                          ? Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ) // Red cross for incorrect
                          : null, // No icon if unanswered
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullQuestionPage(
                              questionId: questionId,
                              isContestCompleted: () => _isContestCompleted,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            answerStatus[questionId] = result;
                          });
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
