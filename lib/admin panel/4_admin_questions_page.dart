import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminQuestionsPage extends StatefulWidget {
  final int contestId;
  final String contestTitle;

  const AdminQuestionsPage({
    Key? key,
    required this.contestId,
    required this.contestTitle,
  }) : super(key: key);

  @override
  _AdminQuestionsPageState createState() => _AdminQuestionsPageState();
}

class _AdminQuestionsPageState extends State<AdminQuestionsPage> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('questions')
          .select('*')
          .eq('contest_id', widget.contestId)
          .order('serial_number', ascending: true);

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCreateQuestionDialog({Map<String, dynamic>? existingQuestion}) {
    showDialog(
      context: context,
      builder: (context) => CreateQuestionDialog(
        contestId: widget.contestId,
        existingQuestion: existingQuestion,
        existingSerialNumbers: questions
            .map((q) => q['serial_number'] as int)
            .where((serial) => 
                existingQuestion == null || 
                serial != existingQuestion['serial_number'])
            .toList(),
        onSaved: _loadQuestions,
      ),
    );
  }

  Future<void> _deleteQuestion(int questionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text(
          'Are you sure you want to delete this question? This will also delete all related submissions.',
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
            .from('questions')
            .delete()
            .eq('id', questionId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted successfully')),
        );
        _loadQuestions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting question: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Questions'),
            Text(
              widget.contestTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No questions yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add questions to this contest',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateQuestionDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.quiz, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                '${questions.length} Question${questions.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Serial: ${questions.map((q) => q['serial_number']).join(', ')}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Questions list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionId = question['id'];
                          final serialNumber = question['serial_number'];
                          final name = question['name'] ?? 'No Name';
                          final questionText = question['question_text'] ?? '';
                          final correctAnswer = question['correct_answer'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '$serialNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                questionText.length > 100
                                    ? '${questionText.substring(0, 100)}...'
                                    : questionText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Full Question:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        questionText,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Correct Answer: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                correctAnswer,
                                                style: TextStyle(
                                                  color: Colors.green.shade900,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => _showCreateQuestionDialog(
                                              existingQuestion: question,
                                            ),
                                            icon: const Icon(Icons.edit, size: 18),
                                            label: const Text('Edit'),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: () => _deleteQuestion(questionId),
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
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateQuestionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
      ),
    );
  }
}

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