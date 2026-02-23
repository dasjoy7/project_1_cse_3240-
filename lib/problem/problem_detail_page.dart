import 'package:flutter/material.dart';
import 'problem_controller.dart';
import 'problem_model.dart';

class ProblemDetailPage extends StatefulWidget {
  final ProblemModel problem;
  final ProblemController controller;

  const ProblemDetailPage({
    super.key,
    required this.problem,
    required this.controller,
  });

  @override
  State<ProblemDetailPage> createState() => _ProblemDetailPageState();
}

class _ProblemDetailPageState extends State<ProblemDetailPage> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;
  bool _hintExpanded = false;
  List<SubmissionModel> _history = [];
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await widget.controller.getSubmissionHistory(widget.problem.id);
    if (mounted) {
      setState(() {
        _history = history;
        _historyLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await widget.controller.submitAnswer(
      problemId: widget.problem.id,
      userAnswer: answer,
      correctAnswer: widget.problem.answer,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result == SubmissionResult.correct) {
      _answerController.clear();
      await _loadHistory();
      _showResultDialog(correct: true);
    } else if (result == SubmissionResult.wrong) {
      await _loadHistory();
      _showResultDialog(correct: false);
    } else {
      // SubmissionResult.failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Try again.')),
      );
    }
  }

  void _showResultDialog({required bool correct}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              correct ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 72,
              color: correct ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              correct ? 'Correct!' : 'Wrong Answer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: correct ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              correct
                  ? 'Great job! You solved this problem.'
                  : 'That\'s not quite right. Try again!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;

    return Scaffold(
      appBar: AppBar(
        title: Text(problem.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyColor(problem.difficulty).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _difficultyColor(problem.difficulty)),
                  ),
                  child: Text(
                    problem.difficulty,
                    style: TextStyle(
                      color: _difficultyColor(problem.difficulty),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(problem.subCategory),
                  backgroundColor: Colors.blueGrey.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              'Problem Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                problem.description,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
            const SizedBox(height: 20),

            // Hint (if available)
            if (problem.hint != null && problem.hint!.isNotEmpty) ...[
              GestureDetector(
                onTap: () => setState(() => _hintExpanded = !_hintExpanded),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text(
                        'Hint',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      const Spacer(),
                      Icon(
                        _hintExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              if (_hintExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    problem.hint!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            // Answer input
            const Text(
              'Your Answer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit Answer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submission history
            const Text(
              'Submission History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _historyLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No submissions yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sub = _history[index];
                return ListTile(
                  leading: Icon(
                    sub.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: sub.isCorrect ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    sub.isCorrect ? 'Correct' : 'Wrong',
                    style: TextStyle(
                      color: sub.isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Text(
                    _formatDate(sub.submittedAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}