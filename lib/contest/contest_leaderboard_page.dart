import 'package:flutter/material.dart';
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
  int totalQuestions = 8; // Default to 8, will be updated

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      currentUserId = Supabase.instance.client.auth.currentUser?.id;

      // Get the actual number of questions for this contest
      final questionsResponse = await Supabase.instance.client
          .from('questions')
          .select('serial_number')
          .eq('contest_id', widget.contestId);

      totalQuestions = questionsResponse.length;

      // Get all submissions for this contest with user details
      final submissions = await Supabase.instance.client
          .from('contest_question_submission')
          .select('''
            user_id,
            rating,
            serial_1,
            serial_2,
            serial_3,
            serial_4,
            serial_5,
            serial_6,
            serial_7,
            serial_8,
            serial_1_attempts,
            serial_2_attempts,
            serial_3_attempts,
            serial_4_attempts,
            serial_5_attempts,
            serial_6_attempts,
            serial_7_attempts,
            serial_8_attempts,
            profile!inner(username, full_name, institution)
          ''')
          .eq('contest_id', widget.contestId);

      // Convert to list and sort with tie-breaking rules
      List<Map<String, dynamic>> sortedSubmissions = List<Map<String, dynamic>>.from(submissions);

      sortedSubmissions.sort((a, b) {
        // Primary: Sort by rating (descending)
        int ratingA = (a['rating'] as num?)?.toInt() ?? 0;
        int ratingB = (b['rating'] as num?)?.toInt() ?? 0;

        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA); // Higher rating first
        }

        // Tie-breaker 1: More solved questions wins
        int solvedA = _countSolvedQuestions(a);
        int solvedB = _countSolvedQuestions(b);

        if (solvedA != solvedB) {
          return solvedB.compareTo(solvedA); // More solved first
        }

        // Tie-breaker 2: Fewer attempts wins
        int attemptsA = _countTotalAttempts(a);
        int attemptsB = _countTotalAttempts(b);

        if (attemptsA != attemptsB) {
          return attemptsA.compareTo(attemptsB); // Fewer attempts first
        }

        // Tie-breaker 3: Alphabetical by username
        String usernameA = a['profile']['username'] ?? '';
        String usernameB = b['profile']['username'] ?? '';
        return usernameA.compareTo(usernameB);
      });

      setState(() {
        leaderboard = sortedSubmissions;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _countSolvedQuestions(Map<String, dynamic> submission) {
    int solved = 0;
    for (int i = 1; i <= totalQuestions; i++) {
      if (submission['serial_$i'] == 1) {
        solved++;
      }
    }
    return solved;
  }

  int _countTotalAttempts(Map<String, dynamic> submission) {
    int attempts = 0;
    for (int i = 1; i <= totalQuestions; i++) {
      attempts += (submission['serial_${i}_attempts'] as int?) ?? 0;
    }
    return attempts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard - $widget.contestTitle'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaderboard.isEmpty
          ? const Center(
        child: Text(
          'No participants yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final entry = leaderboard[index];
          final profile = entry['profile'];
          final username = profile['username'] ?? 'Unknown';
          final fullName = profile['full_name'] ?? 'Unknown';
          final institution = profile['institution'] ?? '';
          final rating = (entry['rating'] as num?)?.toInt() ?? 0;
          final userId = entry['user_id'];
          final isCurrentUser = userId == currentUserId;

          final solvedCount = _countSolvedQuestions(entry);
          final totalAttempts = _countTotalAttempts(entry);

          // Calculate rank considering ties
          int rank = 1;
          if (index > 0) {
            final prevEntry = leaderboard[index - 1];
            final prevRating = (prevEntry['rating'] as num?)?.toInt() ?? 0;
            final prevSolved = _countSolvedQuestions(prevEntry);
            final prevAttempts = _countTotalAttempts(prevEntry);

            // Check if current entry is tied with previous
            if (rating == prevRating &&
                solvedCount == prevSolved &&
                totalAttempts == prevAttempts) {
              // Find the rank of the first person in this tie group
              for (int i = index - 1; i >= 0; i--) {
                final checkEntry = leaderboard[i];
                final checkRating = (checkEntry['rating'] as num?)?.toInt() ?? 0;
                final checkSolved = _countSolvedQuestions(checkEntry);
                final checkAttempts = _countTotalAttempts(checkEntry);

                if (checkRating == rating &&
                    checkSolved == solvedCount &&
                    checkAttempts == totalAttempts) {
                  rank = i + 1;
                } else {
                  break;
                }
              }
            } else {
              rank = index + 1;
            }
          }

          // Medal colors for top 3 ranks
          Color? rankColor;
          IconData? medalIcon;
          if (rank == 1) {
            rankColor = Colors.amber;
            medalIcon = Icons.emoji_events;
          } else if (rank == 2) {
            rankColor = Colors.grey[400];
            medalIcon = Icons.emoji_events;
          } else if (rank == 3) {
            rankColor = Colors.brown[300];
            medalIcon = Icons.emoji_events;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isCurrentUser ? 4 : 1,
            color: isCurrentUser
                ? Colors.blue.shade50
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isCurrentUser
                  ? BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        if (medalIcon != null)
                          Icon(
                            medalIcon,
                            color: rankColor,
                            size: 32,
                          )
                        else
                          Text(
                            '#$rank',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser
                                    ? Colors.blue.shade900
                                    : Colors.black,
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@$username',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (institution.isNotEmpty)
                          Text(
                            institution,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatChip(
                              icon: Icons.check_circle,
                              label: '$solvedCount/$totalQuestions',
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildStatChip(
                              icon: Icons.refresh,
                              label: '$totalAttempts attempts',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  Column(
                    children: [
                      Text(
                        '$rating',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: rating >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}