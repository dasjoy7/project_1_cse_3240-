import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateQuestionDialog extends StatefulWidget {
  final int contestId;
  final Map<String, dynamic>? existingQuestion;
  final List<int> existingSerialNumbers;
  final VoidCallback onSaved;

  const CreateQuestionDialog({
    Key? key,
    required this.contestId,
    this.existingQuestion,
    required this.existingSerialNumbers,
    required this.onSaved,
  }) : super(key: key);

  @override
  _CreateQuestionDialogState createState() => _CreateQuestionDialogState();
}

class _CreateQuestionDialogState extends State<CreateQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionTextController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  
  int _serialNumber = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _nameController.text = widget.existingQuestion!['name'] ?? '';
      _questionTextController.text = widget.existingQuestion!['question_text'] ?? '';
      _correctAnswerController.text = widget.existingQuestion!['correct_answer'] ?? '';
      _serialNumber = widget.existingQuestion!['serial_number'] ?? 1;
    } else {
      // Find next available serial number
      if (widget.existingSerialNumbers.isEmpty) {
        _serialNumber = 1;
      } else {
        _serialNumber = widget.existingSerialNumbers.reduce((a, b) => a > b ? a : b) + 1;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _questionTextController.dispose();
    _correctAnswerController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final questionData = {
        'contest_id': widget.contestId,
        'serial_number': _serialNumber,
        'name': _nameController.text.trim(),
        'question_text': _questionTextController.text.trim(),
        'correct_answer': _correctAnswerController.text.trim(),
      };

      if (widget.existingQuestion != null) {
        // Update existing question
        await Supabase.instance.client
            .from('questions')
            .update(questionData)
            .eq('id', widget.existingQuestion!['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question updated successfully')),
          );
        }
      } else {
        // Create new question
        await Supabase.instance.client
            .from('questions')
            .insert(questionData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question created successfully')),
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
          SnackBar(content: Text('Error saving question: $e')),
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
    final isEditing = widget.existingQuestion != null;
    
    // Get available serial numbers (1-8, excluding already used ones)
    List<int> availableSerials = List.generate(8, (index) => index + 1)
        .where((serial) => 
            !widget.existingSerialNumbers.contains(serial) ||
            serial == _serialNumber)
        .toList();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                    isEditing ? 'Edit Question' : 'Add New Question',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Serial Number
                  DropdownButtonFormField<int>(
                    value: _serialNumber,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                      helperText: 'Question position (1-8)',
                    ),
                    items: availableSerials.map((serial) {
                      return DropdownMenuItem(
                        value: serial,
                        child: Text('Question $serial'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _serialNumber = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a serial number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Question Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                      helperText: 'Short title for the question',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a question name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Question Text
                  TextFormField(
                    controller: _questionTextController,
                    decoration: const InputDecoration(
                      labelText: 'Question Text *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.quiz),
                      helperText: 'The full question statement',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the question text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Correct Answer
                  TextFormField(
                    controller: _correctAnswerController,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.check_circle),
                      helperText: 'The expected correct answer',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the correct answer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Answer matching is case-insensitive. "Hello" will match "hello".',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        onPressed: _isSaving ? null : _saveQuestion,
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