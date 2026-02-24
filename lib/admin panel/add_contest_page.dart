import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddContestPage extends StatefulWidget {
  const AddContestPage({super.key});

  @override
  _AddContestPageState createState() => _AddContestPageState();
}

class _AddContestPageState extends State<AddContestPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = ['Junior', 'Secondary', 'Higher Secondary'];

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<Map<String, TextEditingController>> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    for (final q in _questions) {
      q['name']!.dispose();
      q['question_text']!.dispose();
      q['correct_answer']!.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'name': TextEditingController(),
        'question_text': TextEditingController(),
        'correct_answer': TextEditingController(),
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index]['name']!.dispose();
      _questions[index]['question_text']!.dispose();
      _questions[index]['correct_answer']!.dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Duration _calculateDuration() {
    if (_startTime == null || _endTime == null) return Duration.zero;
    final start = Duration(hours: _startTime!.hour, minutes: _startTime!.minute);
    final end = Duration(hours: _endTime!.hour, minutes: _endTime!.minute);
    return end - start;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '${hours > 0 ? '$hours hours ' : ''}${minutes > 0 ? '$minutes minutes' : ''}'.trim();
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  bool _validate() {
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Please enter a contest title');
      return false;
    }
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return false;
    }
    if (_startTime == null) {
      _showSnack('Please select a start time');
      return false;
    }
    if (_endTime == null) {
      _showSnack('Please select an end time');
      return false;
    }
    final duration = _calculateDuration();
    if (duration.isNegative || duration == Duration.zero) {
      _showSnack('End time must be after start time');
      return false;
    }
    if (_questions.isEmpty) {
      _showSnack('Please add at least one question');
      return false;
    }
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q['name']!.text.trim().isEmpty ||
          q['question_text']!.text.trim().isEmpty ||
          q['correct_answer']!.text.trim().isEmpty) {
        _showSnack('Please fill in all fields for Question ${i + 1}');
        return false;
      }
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submitContest() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    try {
      final duration = _calculateDuration();
      final durationString =
          '${duration.inHours} hours ${duration.inMinutes.remainder(60)} minutes';

      final contestResponse = await _supabase
          .from('contests')
          .insert({
            'title': _titleController.text.trim(),
            'subtitle': _subtitleController.text.trim().isEmpty
                ? null
                : _subtitleController.text.trim(),
            'date': _selectedDate!.toIso8601String().split('T').first,
            'start_time': _timeToString(_startTime!),
            'end_time': _timeToString(_endTime!),
            'duration': durationString,
            'category': _selectedCategory,
          })
          .select('id')
          .single();

      final contestId = contestResponse['id'] as int;

      final questionsData = _questions.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;
        return {
          'contest_id': contestId,
          'serial_number': index + 1,
          'name': q['name']!.text.trim(),
          'question_text': q['question_text']!.text.trim(),
          'correct_answer': q['correct_answer']!.text.trim(),
        };
      }).toList();

      await _supabase.from('questions').insert(questionsData);

      _showSnack('Contest added successfully!');
      _resetForm();
    } catch (e) {
      debugPrint('❌ Error: $e');
      _showSnack('Error: $e');
    }

    setState(() => _isLoading = false);
  }

  void _resetForm() {
    _titleController.clear();
    _subtitleController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
      for (final q in _questions) {
        q['name']!.dispose();
        q['question_text']!.dispose();
        q['correct_answer']!.dispose();
      }
      _questions.clear();
      _addQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Contest"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contest Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                DropdownMenuItem(value: 'Secondary', child: Text('Secondary')),
                DropdownMenuItem(value: 'Higher Secondary', child: Text('Higher Secondary')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 12),

            // Date picker
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              leading: const Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
              title: Text(_selectedDate == null
                  ? 'Select Date *'
                  : 'Date: ${_selectedDate!.toIso8601String().split('T').first}'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            // Start time
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              leading: const Icon(Icons.access_time, color: Color(0xFF1E88E5)),
              title: Text(_startTime == null
                  ? 'Select Start Time *'
                  : 'Start: ${_timeToString(_startTime!)}'),
              onTap: _pickStartTime,
            ),
            const SizedBox(height: 12),

            // End time
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              leading: const Icon(Icons.access_time_filled, color: Color(0xFF1E88E5)),
              title: Text(_endTime == null
                  ? 'Select End Time *'
                  : 'End: ${_timeToString(_endTime!)}'),
              onTap: _pickEndTime,
            ),

            if (_startTime != null && _endTime != null && !duration.isNegative && duration != Duration.zero)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⏱ Duration: ${_formatDuration(duration)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),

            if (_startTime != null && _endTime != null && (duration.isNegative || duration == Duration.zero))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ End time must be after start time',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 24),

            // Questions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Questions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add, color: Color(0xFF1E88E5)),
                  label: const Text('Add Question',
                      style: TextStyle(color: Color(0xFF1E88E5))),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Question ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (_questions.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeQuestion(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: q['name'],
                          decoration: const InputDecoration(
                            labelText: 'Question Name *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: q['question_text'],
                          decoration: const InputDecoration(
                            labelText: 'Question Text *',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: q['correct_answer'],
                          decoration: const InputDecoration(
                            labelText: 'Correct Answer *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitContest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Contest', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}