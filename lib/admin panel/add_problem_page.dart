import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProblemPage extends StatefulWidget {
  const AddProblemPage({super.key});

  @override
  _AddProblemPageState createState() => _AddProblemPageState();
}

class _AddProblemPageState extends State<AddProblemPage> {
  // Form Controllers for the problem details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _hintController = TextEditingController();
  final _answerController = TextEditingController();

  // Form values for Dropdown selections
  String? _mainCategory = 'Mathematical';
  String? _difficulty = 'Easy';

  // List of categories and difficulty levels
  final List<String> _categories = ['Mathematical', 'Logical', 'Puzzle'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  // Supabase instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Function to add problem
  Future<void> _addProblem() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final subCategory = _subCategoryController.text;
    final hint = _hintController.text.isNotEmpty ? _hintController.text : null;
    final answer = _answerController.text;

    if (title.isEmpty || description.isEmpty || subCategory.isEmpty || _mainCategory == null || _difficulty == null || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields')),
      );
      return;
    }

    try {
      await _supabase.from('problems').insert({
        'title': title,
        'description': description,
        'main_category': _mainCategory,
        'sub_category': subCategory,
        'difficulty': _difficulty,
        'hint': hint,
        'answer': answer,
        'total_submission': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem added successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _subCategoryController.clear();
      _hintController.clear();
      _answerController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Problem"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Problem Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Problem Description'),
                maxLines: 4,
              ),
              TextField(
                controller: _subCategoryController,
                decoration: const InputDecoration(labelText: 'Sub Category'),
              ),
              // Main Category Dropdown
              DropdownButtonFormField<String>(
                value: _mainCategory,
                decoration: const InputDecoration(labelText: 'Main Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _mainCategory = value;
                  });
                },
              ),
              // Difficulty Dropdown
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: _difficulties.map((String difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Text(difficulty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value;
                  });
                },
              ),
              TextField(
                controller: _hintController,
                decoration: const InputDecoration(labelText: 'Hint (optional)'),
              ),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProblem,
                child: const Text('Add Problem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5), // Corrected color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}