import 'package:flutter/material.dart';
import 'problem_controller.dart';
import 'problem_model.dart';

// ── Theme constants ────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF4A90D9);
const _kPrimaryDeep= Color(0xFF3574C4);
const _kSurface    = Color(0xFFF7F9FC);
const _kCardWhite  = Color(0xFFFFFFFF);
const _kTextDark   = Color(0xFF1E2A3B);
const _kTextMid    = Color(0xFF5A6A7E);
const _kTextLight  = Color(0xFF8FA0B4);
const _kBorder     = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

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
    final history =
        await widget.controller.getSubmissionHistory(widget.problem.id);
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
        SnackBar(
          content: const Text('Please enter an answer'),
          backgroundColor: _kTextDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Submission failed. Try again.'),
          backgroundColor: const Color(0xFFE05555),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showResultDialog({required bool correct}) {
    final color =
        correct ? const Color(0xFF3DAA6E) : const Color(0xFFE05555);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _kCardWhite,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correct
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                correct ? 'Correct!' : 'Wrong Answer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correct
                    ? 'Great job! You solved this problem.'
                    : "That's not quite right. Try again!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kTextMid, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':   return const Color(0xFF3DAA6E);
      case 'medium': return const Color(0xFFE89B2A);
      case 'hard':   return const Color(0xFFE05555);
      default:       return _kTextLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;
    final diffColor = _difficultyColor(problem.difficulty);

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardWhite,
        foregroundColor: _kTextDark,
        elevation: 0,
        title: Text(
          problem.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _kTextDark,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: const BackButton(color: _kTextDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Tags row ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: diffColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: diffColor.withOpacity(0.30), width: 1),
                  ),
                  child: Text(
                    problem.difficulty,
                    style: TextStyle(
                      color: diffColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    problem.subCategory,
                    style: const TextStyle(
                      color: _kPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Description ─────────────────────────────────────────────────
            _SectionLabel(label: 'Problem Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _kCardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                problem.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: _kTextDark,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Hint ─────────────────────────────────────────────────────────
            if (problem.hint != null && problem.hint!.isNotEmpty) ...[
              GestureDetector(
                onTap: () =>
                    setState(() => _hintExpanded = !_hintExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EC),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft:
                          Radius.circular(_hintExpanded ? 0 : 14),
                      bottomRight:
                          Radius.circular(_hintExpanded ? 0 : 14),
                    ),
                    border: Border.all(
                        color: const Color(0xFFE89B2A).withOpacity(0.30)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE89B2A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Color(0xFFE89B2A), size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Hint',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE89B2A),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _hintExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFE89B2A),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hintExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8EC),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    border: Border(
                      left: BorderSide(
                          color: const Color(0xFFE89B2A).withOpacity(0.30)),
                      right: BorderSide(
                          color: const Color(0xFFE89B2A).withOpacity(0.30)),
                      bottom: BorderSide(
                          color: const Color(0xFFE89B2A).withOpacity(0.30)),
                    ),
                  ),
                  child: Text(
                    problem.hint!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _kTextDark,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            // ── Answer input ─────────────────────────────────────────────────
            _SectionLabel(label: 'Your Answer'),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              style: const TextStyle(color: _kTextDark, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle:
                    const TextStyle(color: _kTextLight, fontSize: 14),
                filled: true,
                fillColor: _kCardWhite,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _kPrimary, width: 1.8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ── Submit button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kPrimary.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submission history ────────────────────────────────────────────
            _SectionLabel(label: 'Submission History'),
            const SizedBox(height: 8),
            _historyLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _kPrimary,
                      strokeWidth: 2.5,
                    ),
                  )
                : _history.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _kCardWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Text(
                          'No submissions yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _kTextLight, fontSize: 14),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: _kCardWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _history.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: _kBorder),
                            itemBuilder: (context, index) {
                              final sub = _history[index];
                              final isCorrect = sub.isCorrect;
                              final subColor = isCorrect
                                  ? const Color(0xFF3DAA6E)
                                  : const Color(0xFFE05555);
                              return ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: subColor.withOpacity(0.10),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isCorrect
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    color: subColor,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  isCorrect ? 'Correct' : 'Wrong',
                                  style: TextStyle(
                                    color: subColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Text(
                                  _formatDate(sub.submittedAt),
                                  style: const TextStyle(
                                    color: _kTextLight,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _kTextLight,
        letterSpacing: 0.8,
      ),
    );
  }
}