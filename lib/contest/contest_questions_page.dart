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
  bool _hasUpdatedProfileRatings = false;
  int _participantCount = 0;

  final List<VoidCallback> _onContestEndCallbacks = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadParticipantCount();
    _startCountdown();
  }

  Future<void> _loadParticipantCount() async {
    try {
      final result = await Supabase.instance.client
          .from('contest_registrations')
          .select('id')
          .eq('contest_id', widget.contestId);
      if (mounted) setState(() => _participantCount = (result as List).length);
    }
    catch (e) {
      print('Error loading participant count: $e');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('contest_id', widget.contestId)
          .order('serial_number', ascending: true);

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        for (var question in questions) {
          answerStatus[question['id'].toString()] = null;
        }
      });
      await _loadAnswerStatus();
    } 
    catch (e) {
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

      setState(() {
        for (var question in questions) {
          final serial = question['serial_number'];
          final value = response?['serial_$serial'];
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
    }
    catch (e) {
      print('Error loading answer status: $e');
    }
  }

  void _startCountdown() {
    _remainingTime = widget.contestEndTime.difference(DateTime.now());

    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
      _isContestStarted = true;
      _isContestCompleted = true;
      return;
    }

    if (DateTime.now().isAfter(widget.contestStartTime)) {
      _isContestStarted = true;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() => _updateRemainingTime());

      if (_remainingTime.inSeconds <= 0) {
        _timer.cancel();
        setState(() => _isContestCompleted = true);
        _notifyContestEnd();

        if (!_hasUpdatedProfileRatings) {
          _hasUpdatedProfileRatings = true;
          _updateProfileRatings();
        }
      }
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (now.isAfter(widget.contestStartTime) && !_isContestStarted) {
      _isContestStarted = true;
    }
    _remainingTime = widget.contestEndTime.difference(now);

    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
      _isContestCompleted = true;
    }

  }

  void _notifyContestEnd() {
    for (var cb in _onContestEndCallbacks) cb();
    _onContestEndCallbacks.clear();
  }

  Future<void> _updateProfileRatings() async {
    try {
      final submissions = await Supabase.instance.client
          .from('contest_question_submission')
          .select('user_id, rating')
          .eq('contest_id', widget.contestId);

      for (var submission in submissions) {
        final userId = submission['user_id'];
        final contestRating = (submission['rating'] as num?)?.toInt() ?? 0;

        final profile = await Supabase.instance.client
            .from('profile')
            .select('rating')
            .eq('id', userId)
            .single();

        int currentRating = (profile['rating'] as num?)?.toInt() ?? 0;
        int newRating = currentRating + contestRating;

        await Supabase.instance.client
            .from('profile')
            .update({'rating': newRating})
            .eq('id', userId);
      }
    } catch (e) {
      print('Error updating profile ratings: $e');
    }
  }

  @override
  void dispose() {
    if (!_isContestCompleted || _remainingTime.inSeconds > 0) {
      _timer.cancel();
    }
    super.dispose();
  }

  String _formatTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerBgColor =>
      _remainingTime.inMinutes < 5 ? Colors.red.shade50 : Colors.blue.shade50;

  Color get _timerFgColor =>
      _remainingTime.inMinutes < 5 ? Colors.red : Colors.blue;

  Widget? _trailingIcon(bool? status) {
    if (status == true) return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    if (status == false) return const Icon(Icons.cancel, color: Colors.red, size: 28);
    return null;
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
                color: _timerBgColor,
                border: Border.all(color: _timerFgColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _isContestCompleted
                        ? 'Contest Ended'
                        : _isContestStarted
                            ? 'Time Remaining'
                            : 'Starts In',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isContestCompleted ? '00:00:00' : _formatTime(_remainingTime),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _timerFgColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

           
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$_participantCount',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),

   
            const Text('Questions:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),


            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final questionName = question['name'] ?? 'No Name';
                  final questionId = question['id'].toString();
                  final serial = question['serial_number'] as int;
                  final status = answerStatus[questionId];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: status == true
                          ? const BorderSide(color: Colors.green, width: 1.5)
                          : status == false
                              ? const BorderSide(color: Colors.red, width: 1.5)
                              : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: status == true
                            ? Colors.green.shade100
                            : status == false
                                ? Colors.red.shade100
                                : Colors.grey.shade200,
                        child: Text(
                          '$serial',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: status == true
                                ? Colors.green.shade800
                                : status == false
                                    ? Colors.red.shade800
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      title: Text(questionName),
                      trailing: _trailingIcon(status),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullQuestionPage(
                              questionId: questionId,
                              isContestCompleted: () => _isContestCompleted,
                              contestId: widget.contestId,
                              onContestEnd: _onContestEndCallbacks.add,
                            ),
                          ),
                        );
                        if (mounted) await _loadAnswerStatus();
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

  Widget _buildSummaryChip({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$count $label',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}