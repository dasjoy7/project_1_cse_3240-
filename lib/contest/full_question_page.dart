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

  // Fetch full question details from Supabase
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
      });
    } catch (e) {
      print('Error fetching question: $e');
    }
  }

  // Handle answer submission and check correctness
  void _submitAnswer() {
    final submittedAnswer = _answerController.text.trim();

    if (submittedAnswer == _correctAnswer) {
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
    _loadQuestion();  // Load the full question when the page is initialized
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
              'Question Details for Question ${widget.questionId}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the full question text and description
            Text(
              _questionText.isNotEmpty ? _questionText : 'Loading question...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Submit your answer',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,  // Updated to allow text input
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,  // Handle answer submission
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
      ),
    );
  }
}
