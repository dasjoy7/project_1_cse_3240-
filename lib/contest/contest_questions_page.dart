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
  Map<String, bool?> answerStatus = {};

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

  Future<void> _loadQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('contest_id', widget.contestId);

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        for (var question in questions) {
          answerStatus[question['id'].toString()] = null;
        }
      });

      await _loadAnswerStatus(); // ✅ Load saved marks after questions are ready
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  Future<void> _loadAnswerStatus() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      final response = await Supabase.instance.client
          .from('contest_question_submission')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('contest_id', widget.contestId)
          .maybeSingle();

      if (response == null) return;

      setState(() {
        for (var question in questions) {
          final serial = question['serial_number'];
          final value = response['serial_$serial'];
          final questionId = question['id'].toString();

          if (value == 1) {
            answerStatus[questionId] = true;
          } else if (value == 0) {
            answerStatus[questionId] = false;
          } else {
            answerStatus[questionId] = null;
          }
        }
      });
    } catch (e) {
      print('Error loading answer status: $e');
    }
  }

  void _startCountdown() {
    _remainingTime = widget.contestStartTime.difference(DateTime.now());

    if (_remainingTime.isNegative) {
      setState(() {
        _remainingTime = Duration(seconds: 0);
        _isContestStarted = true;
      });
    }

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
            Text(widget.contestSubtitle, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
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
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 20),
            const Text(
              'Questions:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final questionName = question['name'] ?? 'No Name';
                  final questionText = question['question_text'] ?? 'No Text';
                  final questionId = question['id'].toString();
                  final status = answerStatus[questionId];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        '${question['serial_number']}. $questionName',
                      ),
                      subtitle: Text(questionText),
                      trailing: status == true
                          ? const Icon(Icons.check_circle,
                              color: Colors.green, size: 28)
                          : status == false
                              ? const Icon(Icons.cancel,
                                  color: Colors.red, size: 28)
                              : null,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullQuestionPage(
                              questionId: questionId,
                              isContestCompleted: () => _isContestCompleted,
                              contestId: widget.contestId,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            answerStatus[questionId] = result as bool;
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