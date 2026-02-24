import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageContestsPage extends StatefulWidget {
  const ManageContestsPage({super.key});

  @override
  _ManageContestsPageState createState() => _ManageContestsPageState();
}

class _ManageContestsPageState extends State<ManageContestsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _contests = [];
  bool _isLoading = true;

  final List<String> _categories = ['Junior', 'Secondary', 'Higher Secondary'];

  @override
  void initState() {
    super.initState();
    _fetchContests();
  }

  Future<void> _fetchContests() async {
    try {
      final data = await _supabase
          .from('contests')
          .select()
          .order('date', ascending: false);
      setState(() {
        _contests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Error fetching contests: $e');
    }
  }

  Future<void> _deleteContest(int contestId) async {
    try {
      await _supabase.from('contests').delete().eq('id', contestId);
      setState(() {
        _contests.removeWhere((c) => c['id'] == contestId);
      });
      _showSnack('Contest deleted successfully!');
    } catch (e) {
      _showSnack('Error deleting contest: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showEditDialog(Map<String, dynamic> contest) {
    final titleController = TextEditingController(text: contest['title']);
    final subtitleController = TextEditingController(text: contest['subtitle'] ?? '');
    String? selectedCategory = contest['category'];
    DateTime? selectedDate = contest['date'] != null
        ? DateTime.tryParse(contest['date'])
        : null;
    TimeOfDay? startTime = _parseTime(contest['start_time']);
    TimeOfDay? endTime = _parseTime(contest['end_time']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Edit Contest',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _categories.contains(selectedCategory)
                          ? selectedCategory
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                        DropdownMenuItem(value: 'Secondary', child: Text('Secondary')),
                        DropdownMenuItem(value: 'Higher Secondary', child: Text('Higher Secondary')),
                      ],
                      onChanged: (value) =>
                          setSheetState(() => selectedCategory = value),
                    ),
                    const SizedBox(height: 12),

                    // Date
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      leading: const Icon(Icons.calendar_today,
                          color: Color(0xFF1E88E5)),
                      title: Text(selectedDate == null
                          ? 'Select Date *'
                          : 'Date: ${selectedDate!.toIso8601String().split('T').first}'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Start time
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      leading: const Icon(Icons.access_time,
                          color: Color(0xFF1E88E5)),
                      title: Text(startTime == null
                          ? 'Select Start Time *'
                          : 'Start: ${_timeToString(startTime!)}'),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setSheetState(() => startTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // End time
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      leading: const Icon(Icons.access_time_filled,
                          color: Color(0xFF1E88E5)),
                      title: Text(endTime == null
                          ? 'Select End Time *'
                          : 'End: ${_timeToString(endTime!)}'),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setSheetState(() => endTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            _showSnack('Title is required');
                            return;
                          }
                          if (selectedDate == null || startTime == null || endTime == null) {
                            _showSnack('Please fill date and times');
                            return;
                          }

                          final start = Duration(hours: startTime!.hour, minutes: startTime!.minute);
                          final end = Duration(hours: endTime!.hour, minutes: endTime!.minute);
                          final duration = end - start;

                          if (duration.isNegative || duration == Duration.zero) {
                            _showSnack('End time must be after start time');
                            return;
                          }

                          final durationString =
                              '${duration.inHours} hours ${duration.inMinutes.remainder(60)} minutes';

                          try {
                            await _supabase.from('contests').update({
                              'title': titleController.text.trim(),
                              'subtitle': subtitleController.text.trim().isEmpty
                                  ? null
                                  : subtitleController.text.trim(),
                              'category': selectedCategory,
                              'date': selectedDate!.toIso8601String().split('T').first,
                              'start_time': _timeToString(startTime!),
                              'end_time': _timeToString(endTime!),
                              'duration': durationString,
                            }).eq('id', contest['id']);

                            Navigator.pop(context);
                            await _fetchContests();
                            _showSnack('Contest updated successfully!');
                          } catch (e) {
                            _showSnack('Error updating contest: $e');
                          }
                        },
                        child: const Text('Save Changes',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0);
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Color _statusColor(String? status) {
    switch (status) {
      case 'ongoing':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'finished':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Contests"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchContests();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contests.isEmpty
              ? const Center(child: Text('No contests found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _contests.length,
                  itemBuilder: (context, index) {
                    final contest = _contests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          contest['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (contest['subtitle'] != null)
                              Text(contest['subtitle']),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (contest['category'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E88E5)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      contest['category'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1E88E5)),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(contest['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    contest['status'] ?? 'unknown',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _statusColor(contest['status'])),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📅 ${contest['date']}  ⏰ ${contest['start_time']} - ${contest['end_time']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF1E88E5)),
                              onPressed: () => _showEditDialog(
                                  Map<String, dynamic>.from(contest)),
                            ),
                            // Delete
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Contest"),
                                    content: const Text(
                                        "Are you sure? This will also delete all questions in this contest."),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteContest(contest['id']);
                                        },
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}