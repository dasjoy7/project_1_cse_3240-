import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/individual_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContestLeaderboardPage extends StatefulWidget {
  final String contestId;
  final String contestTitle;

  const ContestLeaderboardPage({
    Key? key,
    required this.contestId,
    required this.contestTitle,
  }) : super(key: key);

  @override
  _ContestLeaderboardPageState createState() => _ContestLeaderboardPageState();
}

class _ContestLeaderboardPageState extends State<ContestLeaderboardPage> {
  List<Map<String, dynamic>> leaderboard = [];
  bool isLoading = true;
  String? currentUserId;
  int totalQuestions = 8; // actual count fetched from DB

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      currentUserId = Supabase.instance.client.auth.currentUser?.id;

      // Fetch actual question count for this contest
      final questions = await Supabase.instance.client
          .from('questions')
          .select('serial_number')
          .eq('contest_id', widget.contestId);
      final qCount = (questions as List).length;

      final submissions = await Supabase.instance.client
          .from('contest_question_submission')
          .select('''
            user_id,
            rating,
            serial_1, serial_2, serial_3, serial_4,
            serial_5, serial_6, serial_7, serial_8,
            serial_1_attempts, serial_2_attempts, serial_3_attempts, serial_4_attempts,
            serial_5_attempts, serial_6_attempts, serial_7_attempts, serial_8_attempts,
            profile!inner(id, username, full_name, institution)
          ''')
          .eq('contest_id', widget.contestId)
          .order('rating', ascending: false);

      setState(() {
        totalQuestions = qCount > 0 ? qCount : 8;
        leaderboard = List<Map<String, dynamic>>.from(submissions);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() => isLoading = false);
    }
  }

  int _countSolved(Map<String, dynamic> s) {
    int c = 0;
    for (int i = 1; i <= totalQuestions; i++) {
      if (s['serial_$i'] == 1) c++;
    }
    return c;
  }

  /// Per-question status squares — only renders actual questions
  Widget _buildQuestionGrid(Map<String, dynamic> s) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(totalQuestions, (i) {
        final serial = i + 1;
        final status = s['serial_$serial'];
        final attempts = (s['serial_${serial}_attempts'] as int?) ?? 0;

        Color bg;
        Color border;
        IconData icon;

        if (status == 1) {
          bg = Colors.green.shade100;
          border = Colors.green;
          icon = Icons.check;
        } else if (status == 0 && attempts > 0) {
          bg = Colors.red.shade100;
          border = Colors.red;
          icon = Icons.close;
        } else {
          bg = Colors.grey.shade100;
          border = Colors.grey.shade400;
          icon = Icons.remove;
        }

        return Tooltip(
          message: status == 1
              ? 'Q$serial: Solved ($attempts attempt${attempts != 1 ? 's' : ''})'
              : attempts > 0
                  ? 'Q$serial: Wrong ($attempts attempt${attempts != 1 ? 's' : ''})'
                  : 'Q$serial: Not attempted',
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 14, color: border),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard — ${widget.contestTitle}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaderboard.isEmpty
              ? const Center(
                  child: Text('No participants yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    final profile = entry['profile'];
                    final userId = profile['id'] as String;
                    final username = profile['username'] ?? 'Unknown';
                    final fullName = profile['full_name'] ?? 'Unknown';
                    final institution = profile['institution'] ?? '';
                    final rating = (entry['rating'] as num?)?.toInt() ?? 0;
                    final isCurrentUser = userId == currentUserId;
                    final solved = _countSolved(entry);
                    final rank = index + 1;

                    Color? rankColor;
                    IconData? medalIcon;
                    if (rank == 1) { rankColor = Colors.amber; medalIcon = Icons.emoji_events; }
                    else if (rank == 2) { rankColor = Colors.grey[400]; medalIcon = Icons.emoji_events; }
                    else if (rank == 3) { rankColor = Colors.brown[300]; medalIcon = Icons.emoji_events; }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: isCurrentUser ? 3 : 1,
                      color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isCurrentUser
                            ? const BorderSide(color: Colors.blue, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IndividualProfilePage(userId: userId),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Rank / medal
                                  SizedBox(
                                    width: 40,
                                    child: medalIcon != null
                                        ? Icon(medalIcon, color: rankColor, size: 26)
                                        : Text(
                                            '#$rank',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Name + username
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                fullName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isCurrentUser
                                                      ? Colors.blue.shade900
                                                      : Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isCurrentUser)
                                              Container(
                                                margin: const EdgeInsets.only(left: 6),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text('You',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                        Text('@$username',
                                            style: TextStyle(
                                                fontSize: 12, color: Colors.grey[600])),
                                        if (institution.isNotEmpty)
                                          Text(institution,
                                              style: TextStyle(
                                                  fontSize: 11, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                  // Solved count + rating
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${rating >= 0 ? '' : ''}$rating pts',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: rating >= 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                      Text(
                                        '$solved/$totalQuestions solved',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildQuestionGrid(entry),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}