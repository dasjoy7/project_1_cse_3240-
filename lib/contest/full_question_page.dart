import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FullQuestionPage extends StatefulWidget {
  final String questionId;

  const FullQuestionPage({Key? key, required this.questionId}) : super(key: key);

  @override
  _FullQuestionPageState createState() => _FullQuestionPageState();
}

class _FullQuestionPageState extends State<FullQuestionPage> {
  TextEditingController _answerController = TextEditingController();
  String _answerStatus = ''; // Track the answer status (correct/incorrect)
  bool _isSubmitted = false; // Track whether the user has submitted their answer
  String _questionText = '';
  String _correctAnswer = ''; // Store the correct answer as a string
  bool _isContestCompleted = false; // Track if contest has completed
  bool _isLoading = true; // Track if data is still loading

  // Fetch question and contest details from Supabase
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
        _correctAnswer = question['correct_answer']; // Assuming correct_answer is stored as a string
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching question: $e');
    }
  }

  // Check if the contest is completed and disable the submit button
  Future<void> _checkContestStatus() async {
    try {
      final contestResponse = await Supabase.instance.client
          .from('contests')
          .select('*')
          .eq('id', widget.questionId) // Assuming `questionId` links to `contestId`
          .single();

      final contestEndTime = DateTime.parse(contestResponse['end_time']);

      if (DateTime.now().isAfter(contestEndTime)) {
        setState(() {
          _isContestCompleted = true; // Contest has ended
        });
      }
    } catch (e) {
      print('Error checking contest status: $e');
    }
  }

  // Handle answer submission and check correctness
  void _submitAnswer() {
    final submittedAnswer = _answerController.text.trim();

    if (submittedAnswer.isEmpty) {
      setState(() {
        _answerStatus = 'Please enter an answer.';
      });
      return;
    }

    if (submittedAnswer.toLowerCase() == _correctAnswer.toLowerCase()) {
      setState(() {
        _answerStatus = 'Correct!';
        _isSubmitted = true;
      });
    } else {
      setState(() {
        _answerStatus = 'Incorrect! Try again.';
        _isSubmitted = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuestion();
    _checkContestStatus(); // Check contest status when page initializes
  }

  @override
  void dispose() {
    _answerController.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Full Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show loading spinner while fetching the question
            if (_isLoading)
              Center(child: CircularProgressIndicator()),

            // Display question details when loaded
            if (!_isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _questionText.isNotEmpty ? _questionText : 'No question available.',
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
                    onPressed: _isContestCompleted || _isSubmitted ? null : _submitAnswer, // Disable button after submission or contest end
                    child: Text('Submit Answer'),
                  ),
                  SizedBox(height: 20),
                  if (_isSubmitted)
                    Text(
                      _answerStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _answerStatus == 'Correct!' ? Colors.green : Colors.red,
                      ),
                    ),
                  if (_isSubmitted)
                    Icon(
                      _answerStatus == 'Correct!' ? Icons.check_circle : Icons.cancel,
                      color: _answerStatus == 'Correct!' ? Colors.green : Colors.red,
                      size: 40,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
