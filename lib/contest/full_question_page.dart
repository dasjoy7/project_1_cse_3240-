import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullQuestionPage extends StatefulWidget {
  final String questionId;
  final bool Function() isContestCompleted;
  final String contestId;

  const FullQuestionPage({
    Key? key,
    required this.questionId,
    required this.isContestCompleted,
    required this.contestId,
  }) : super(key: key);

  @override
  _FullQuestionPageState createState() => _FullQuestionPageState();
}

class _FullQuestionPageState extends State<FullQuestionPage> {
  final TextEditingController _answerController = TextEditingController();
  String _answerStatus = '';
  bool _isSubmitted = false;
  String _questionText = '';
  String _correctAnswer = '';
  int _serialNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      final question = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('id', widget.questionId)
          .single();

      setState(() {
        _questionText = question['question_text'];
        _correctAnswer = question['correct_answer'];
        _serialNumber = question['serial_number'];
      });
    } catch (e) {
      print('Error fetching question: $e');
    }
  }

  void _submitAnswer() async {
    final submittedAnswer = _answerController.text.trim();

    if (widget.isContestCompleted()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Contest Ended"),
          content: const Text("Submissions are closed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (submittedAnswer.isEmpty) {
      setState(() {
        _answerStatus = 'Please enter an answer.';
      });
      return;
    }

    bool isCorrect =
        submittedAnswer.toLowerCase() == _correctAnswer.toLowerCase();

    setState(() {
      _isSubmitted = true;
      _answerStatus = isCorrect ? 'Correct!' : 'Incorrect! Try again.';
    });

    // Update the user's submission in the contest_question_submission table
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.id;

      try {
        await Supabase.instance.client
            .from('contest_question_submission')
            .update({
              'serial_$_serialNumber': isCorrect ? 1 : 0,
            })
            .eq('user_id', userId)
            .eq('contest_id', widget.contestId);
      } catch (e) {
        print('Error updating submission: $e');
      }
    }

    // Show result dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? 'Correct!' : 'Wrong!',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isCorrect
              ? 'Well done! Your answer is correct.'
              : 'That was incorrect. Try again!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, isCorrect); // Return result
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _questionText.isNotEmpty
                  ? _questionText
                  : 'No question available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Submit your answer',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.isContestCompleted() ? null : _submitAnswer,
              child: const Text('Submit Answer'),
            ),
            const SizedBox(height: 20),
            if (_isSubmitted)
              Text(
                _answerStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      _answerStatus == 'Correct!' ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}