import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullQuestionPage extends StatefulWidget {
  final String questionId;
  final bool Function() isContestCompleted;
  final String contestId;
  final void Function(VoidCallback) onContestEnd;

  const FullQuestionPage({
    Key? key,
    required this.questionId,
    required this.isContestCompleted,
    required this.contestId,
    required this.onContestEnd,
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
    widget.onContestEnd(() {
      if (mounted) {
        setState(() {});
        _showContestEndedDialog();
      }
    });
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

  void _showContestEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Contest Ended'),
        content: const Text('Time is up! Submissions are now closed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to contest page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        // First, get current attempts
        final existing = await Supabase.instance.client
            .from('contest_question_submission')
            .select('serial_${_serialNumber}_attempts')
            .eq('user_id', userId)
            .eq('contest_id', widget.contestId)
            .maybeSingle();

        int currentAttempts = 0;
        if (existing != null &&
            existing['serial_${_serialNumber}_attempts'] != null) {
          currentAttempts = existing['serial_${_serialNumber}_attempts'];
        }

        // Increment attempts
        int newAttempts = currentAttempts + 1;

        // Prepare update data
        Map<String, dynamic> updateData = {
          'serial_${_serialNumber}_attempts': newAttempts,
        };

        // Only update status if correct
        if (isCorrect) {
          updateData['serial_$_serialNumber'] = 1;
        } else {
          // Mark as attempted but wrong (0)
          updateData['serial_$_serialNumber'] = 0;
        }

        await Supabase.instance.client
            .from('contest_question_submission')
            .update(updateData)
            .eq('user_id', userId)
            .eq('contest_id', widget.contestId);

        // Recalculate total rating (for both correct and wrong answers)
        await _updateRating(userId);
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

  Future<void> _updateRating(String userId) async {
    try {
      // First, get the actual number of questions for this contest
      final questionsResponse = await Supabase.instance.client
          .from('questions')
          .select('serial_number')
          .eq('contest_id', widget.contestId);

      int totalQuestions = questionsResponse.length;

      // Get user's submission data
      final submission = await Supabase.instance.client
          .from('contest_question_submission')
          .select('*')
          .eq('user_id', userId)
          .eq('contest_id', widget.contestId)
          .single();

      int totalRating = 0;

      // Calculate rating for each question (up to total questions in contest)
      for (int i = 1; i <= totalQuestions; i++) {
        int? status = submission['serial_$i'];
        int? attempts = submission['serial_${i}_attempts'];

        // If question was attempted
        if (attempts != null && attempts > 0) {
          if (status == 1) {
            // Correct answer
            // Base points = serial number × 10 (Q1=10, Q2=20, Q3=30...)
            int basePoints = i * 10;

            // Penalty for wrong attempts (deduct 2 points per wrong attempt)
            int wrongAttempts = attempts - 1; // -1 because final attempt was correct
            int penalty = wrongAttempts * 2;

            // Final score for this question (minimum 1 point)
            int questionScore = basePoints - penalty;
            if (questionScore < 1) questionScore = 1;

            totalRating += questionScore;
          } else if (status == 0) {
            // Wrong answer - negative marking (-2 points per wrong attempt)
            int negativeMarks = attempts * 2;
            totalRating -= negativeMarks;
          }
        }
      }

      // Update rating in contest_question_submission table
      await Supabase.instance.client
          .from('contest_question_submission')
          .update({'rating': totalRating})
          .eq('user_id', userId)
          .eq('contest_id', widget.contestId);

      print('Contest rating updated: $totalRating (contest has $totalQuestions questions)');
    } catch (e) {
      print('Error updating rating: $e');
    }
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