import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '3_create_contest_dialog.dart';
import '4_admin_questions_page.dart';

class AdminContestsPage extends StatefulWidget {
  const AdminContestsPage({Key? key}) : super(key: key);

  @override
  _AdminContestsPageState createState() => _AdminContestsPageState();
}

class _AdminContestsPageState extends State<AdminContestsPage> {
  List<Map<String, dynamic>> contests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContests();
  }

  Future<void> _loadContests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('contests')
          .select('*')
          .order('date', ascending: false)
          .order('start_time', ascending: false);

      setState(() {
        contests = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading contests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCreateContestDialog({Map<String, dynamic>? existingContest}) {
    showDialog(
      context: context,
      builder: (context) => CreateContestDialog(
        existingContest: existingContest,
        onSaved: _loadContests,
      ),
    );
  }

  Future<void> _deleteContest(int contestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contest'),
        content: const Text(
          'Are you sure you want to delete this contest? This will also delete all associated questions and submissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('contests')
            .delete()
            .eq('id', contestId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contest deleted successfully')),
        );
        _loadContests();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting contest: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Contests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContests,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No contests yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateContestDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Contest'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contests.length,
                  itemBuilder: (context, index) {
                    final contest = contests[index];
                    final title = contest['title'] ?? 'No Title';
                    final subtitle = contest['subtitle'] ?? '';
                    final date = contest['date'] ?? '';
                    final startTime = contest['start_time'] ?? '';
                    final endTime = contest['end_time'] ?? '';
                    final category = contest['category'] ?? 'No Category';
                    final status = contest['status'] ?? 'upcoming';
                    final contestId = contest['id'];

                    // Status color
                    Color statusColor;
                    IconData statusIcon;
                    switch (status.toLowerCase()) {
                      case 'live':
                        statusColor = Colors.green;
                        statusIcon = Icons.play_circle;
                        break;
                      case 'completed':
                        statusColor = Colors.grey;
                        statusIcon = Icons.check_circle;
                        break;
                      default:
                        statusColor = Colors.blue;
                        statusIcon = Icons.schedule;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (subtitle.isNotEmpty)
                                        Text(
                                          subtitle,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 16, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(date, style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('$startTime - $endTime', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(category, style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminQuestionsPage(
                                          contestId: contestId,
                                          contestTitle: title,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.quiz, size: 18),
                                  label: const Text('Questions'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.purple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _showCreateContestDialog(
                                    existingContest: contest,
                                  ),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _deleteContest(contestId),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateContestDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Contest'),
      ),
    );
  }
}