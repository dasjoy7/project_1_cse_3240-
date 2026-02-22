import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateContestDialog extends StatefulWidget {
  final Map<String, dynamic>? existingContest;
  final VoidCallback onSaved;

  const CreateContestDialog({
    Key? key,
    this.existingContest,
    required this.onSaved,
  }) : super(key: key);

  @override
  _CreateContestDialogState createState() => _CreateContestDialogState();
}

class _CreateContestDialogState extends State<CreateContestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCategory = 'Junior';
  
  final List<String> _categories = ['Junior', 'Secondary', 'Higher Sec'];
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingContest != null) {
      _titleController.text = widget.existingContest!['title'] ?? '';
      _subtitleController.text = widget.existingContest!['subtitle'] ?? '';
      _selectedCategory = widget.existingContest!['category'] ?? 'Junior';
      
      // Parse date
      try {
        _selectedDate = DateTime.parse(widget.existingContest!['date']);
      } catch (e) {
        _selectedDate = null;
      }
      
      // Parse times
      try {
        final startTimeStr = widget.existingContest!['start_time'];
        final startParts = startTimeStr.split(':');
        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
      } catch (e) {
        _startTime = null;
      }
      
      try {
        final endTimeStr = widget.existingContest!['end_time'];
        final endParts = endTimeStr.split(':');
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      } catch (e) {
        _endTime = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  Future<void> _saveContest() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Calculate duration
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      int durationMinutes = endMinutes - startMinutes;
      
      if (durationMinutes <= 0) {
        durationMinutes += 24 * 60; // Add 24 hours if end time is next day
      }
      
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      final durationString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';

      final contestData = {
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'date': _selectedDate!.toIso8601String().split('T')[0],
        'start_time': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00',
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00',
        'duration': durationString,
        'category': _selectedCategory,
      };

      if (widget.existingContest != null) {
        // Update existing contest
        await Supabase.instance.client
            .from('contests')
            .update(contestData)
            .eq('id', widget.existingContest!['id']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contest updated successfully')),
          );
        }
      } else {
        // Create new contest
        await Supabase.instance.client
            .from('contests')
            .insert(contestData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contest created successfully')),
          );
        }
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contest: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingContest != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Contest' : 'Create New Contest',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Contest Title *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  TextFormField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Contest Date *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                            : 'Select Date',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Start Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectStartTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Time *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _startTime != null
                                  ? _startTime!.format(context)
                                  : 'Select Time',
                              style: TextStyle(
                                color: _startTime != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectEndTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Time *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _endTime != null
                                  ? _endTime!.format(context)
                                  : 'Select Time',
                              style: TextStyle(
                                color: _endTime != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveContest,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}