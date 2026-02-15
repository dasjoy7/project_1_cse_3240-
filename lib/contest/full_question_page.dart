import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullQuestionPage extends StatefulWidget {
  final String questionId;
  final bool Function() isContestCompleted;

  const FullQuestionPage({
    Key? key,
    required this.questionId,
    required this.isContestCompleted,
  }) : super(key: key);

  @override
  _FullQuestionPageState createState() => _FullQuestionPageState();
}

class _FullQuestionPageState extends State<FullQuestionPage> {
  TextEditingController _answerController = TextEditingController();
  String _answerStatus = '';
  bool _isSubmitted = false;
  String _questionText = '';
  String _correctAnswer = '';

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('id', widget.questionId)
          .single();
      final question = response;

      setState(() {
        _questionText = question['question_text'];
        _correctAnswer = question['correct_answer'];
      });
    } catch (e) {
      print('Error fetching question: $e');
    }
  }

  void _submitAnswer() {

    final submittedAnswer = _answerController.text.trim();

    if (widget.isContestCompleted()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Contest Ended"),
          content: Text("Submissions are closed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
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

    if (isCorrect) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Correct!'),
            content: const Text('Well done!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // Go back to ContestQuestionsPage with "correct"
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Wrong answer → just show the status below the TextField
      setState(() {
        _answerStatus = 'Incorrect! Try again.';
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Wrong!'),
              content: const Text('Try Again!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(
                      context,
                      false,
                    ); // Go back to ContestQuestionsPage with "correct"
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Full Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _questionText.isNotEmpty
                  ? _questionText
                  : 'No question available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Submit your answer',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.isContestCompleted() ? null : _submitAnswer,
              child: Text('Submit Answer'),
            ),
            SizedBox(height: 20),
            if (_isSubmitted)
              Text(
                _answerStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _answerStatus == 'Correct!'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
