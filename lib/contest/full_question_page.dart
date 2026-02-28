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

  String _questionText = '';
  String _questionName = '';
  String _correctAnswer = '';
  int _serialNumber = 0;

  bool _isAlreadyCorrect = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionAndStatus();
    widget.onContestEnd(() {
      if (mounted) {
        setState(() {});
        _showContestEndedDialog();
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // ─── Load question + existing submission status from DB ──────────────────
  Future<void> _loadQuestionAndStatus() async {
    try {
      final question = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('id', widget.questionId)
          .single();

      final serial = question['serial_number'] as int;

      setState(() {
        _questionText = question['question_text'] ?? '';
        _questionName = question['name'] ?? '';
        _correctAnswer = question['correct_answer'] ?? '';
        _serialNumber = serial;
      });

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        final submission = await Supabase.instance.client
            .from('contest_question_submission')
            .select('serial_$serial, serial_${serial}_attempts')
            .eq('user_id', currentUser.id)
            .eq('contest_id', widget.contestId)
            .maybeSingle();

        if (submission != null) {
          final status = submission['serial_$serial'] as int?;
          setState(() {
            _isAlreadyCorrect = (status == 1);
          });
        }
      }
    } catch (e) {
      print('Error loading question: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Contest ended dialog ────────────────────────────────────────────────
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── Rating calculation from a full submission row ───────────────────────
  int _calculateRating(Map<String, dynamic> row) {
    int total = 0;
    for (int i = 1; i <= 8; i++) {
      final status = row['serial_$i'] as int?;
      final attempts = (row['serial_${i}_attempts'] as int?) ?? 0;
      if (attempts == 0) continue;

      if (status == 1) {
        // Base = serial × 10; penalty = 2 pts per wrong attempt before solving
        final base = i * 10;
        final wrongBefore = attempts - 1;
        final score = (base - wrongBefore * 2).clamp(1, base);
        total += score;
      } else if (status == 0) {
        // −2 pts per wrong attempt, no correct yet
        total -= attempts * 2;
      }
    }
    return total;
  }

  // ─── Submit answer ───────────────────────────────────────────────────────
  //
  //  KEY FIX: Uses upsert() instead of update().
  //  Your RLS only has INSERT + SELECT policies — UPDATE is blocked.
  //  upsert() issues  INSERT … ON CONFLICT (user_id, contest_id) DO UPDATE
  //  which is covered by the INSERT policy in Supabase.
  //
  Future<void> _submitAnswer() async {
    if (_isSubmitting) return;
    final submittedAnswer = _answerController.text.trim();

    if (widget.isContestCompleted()) {
      _showContestEndedDialog();
      return;
    }

    if (_isAlreadyCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already solved correctly!')),
      );
      return;
    }

    if (submittedAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final isCorrect =
        submittedAnswer.toLowerCase() == _correctAnswer.toLowerCase();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final userId = currentUser.id;

    try {
      // 1. Fetch the full existing row — we need every column for upsert
      final existing = await Supabase.instance.client
          .from('contest_question_submission')
          .select('*')
          .eq('user_id', userId)
          .eq('contest_id', widget.contestId)
          .maybeSingle();

      if (existing == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Submission record not found. Please re-open the contest.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      // Never overwrite a correct answer with a wrong one
      if (existing['serial_$_serialNumber'] == 1) {
        setState(() {
          _isAlreadyCorrect = true;
          _isSubmitting = false;
        });
        return;
      }

      // 2. Patch only the fields that change
      final int currentAttempts =
          (existing['serial_${_serialNumber}_attempts'] as int?) ?? 0;
      final int newAttempts = currentAttempts + 1;

      final Map<String, dynamic> updatedRow =
          Map<String, dynamic>.from(existing);
      updatedRow['serial_$_serialNumber'] = isCorrect ? 1 : 0;
      updatedRow['serial_${_serialNumber}_attempts'] = newAttempts;

      // 3. Recalculate rating from the patched row
      final int newRating = _calculateRating(updatedRow);
      updatedRow['rating'] = newRating;

      // 4. Upsert — INSERT … ON CONFLICT (user_id, contest_id) DO UPDATE
      //    This works with INSERT-only RLS because Supabase evaluates the
      //    INSERT policy for upsert operations.
      await Supabase.instance.client
          .from('contest_question_submission')
          .upsert(
            updatedRow,
            onConflict: 'user_id,contest_id',
          );

      print('✅ Upserted — serial_$_serialNumber: ${isCorrect ? 1 : 0}, '
          'attempts: $newAttempts, rating: $newRating');

      // 5. Update local UI state
      setState(() {
        if (isCorrect) _isAlreadyCorrect = true;
        _answerController.clear();
        _isSubmitting = false;
      });
    } catch (e) {
      print('Error submitting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isSubmitting = false);
      return;
    }

    // 6. Result dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Navigator.pop(context); // close dialog
              if (isCorrect) {
                Navigator.pop(context, true); // go back to question list
              }
              // Wrong: stay on this page so user can retry
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isContestOver = widget.isContestCompleted();
    final bool canSubmit =
        !isContestOver && !_isAlreadyCorrect && !_isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(_questionName.isNotEmpty ? _questionName : 'Question'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Text(
                    _questionText.isNotEmpty
                        ? _questionText
                        : 'No question available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Answer input — hidden when already solved or contest over
                  if (!_isAlreadyCorrect && !isContestOver) ...[
                    TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        labelText: 'Your answer',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitAnswer(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: canSubmit ? _submitAnswer : null,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                            _isSubmitting ? 'Submitting…' : 'Submit Answer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],



                  if (isContestOver && !_isAlreadyCorrect)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Contest has ended. Submissions are closed.',
                          style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}