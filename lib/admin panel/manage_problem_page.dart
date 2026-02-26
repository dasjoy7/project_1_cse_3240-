import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProblemsPage extends StatefulWidget {
  const ManageProblemsPage({super.key});

  @override
  State<ManageProblemsPage> createState() => _ManageProblemsPageState();
}

class _ManageProblemsPageState extends State<ManageProblemsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _problems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  Future<void> _fetchProblems() async {
    try {
      final data = await _supabase.from('problems').select().order('created_at');
      setState(() {
        _problems = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching problems: $e', isError: true);
    }
  }

  Future<void> _deleteProblem(String problemId) async {
    try {
      await _supabase.from('problems').delete().eq('id', problemId);
      setState(() => _problems.removeWhere((p) => p['id'] == problemId));
      _showSnackBar('Problem deleted successfully!');
    } catch (e) {
      _showSnackBar('Error deleting problem: $e', isError: true);
    }
  }

  Future<void> _updateProblem(String problemId, Map<String, dynamic> updated) async {
    try {
      await _supabase.from('problems').update(updated).eq('id', problemId);
      await _fetchProblems();
      _showSnackBar('Problem updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating problem: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ── View Problem Dialog ──
  void _showViewDialog(Map<String, dynamic> problem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      problem['title'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              _viewRow(Icons.category, "Category", "${problem['main_category']} → ${problem['sub_category']}"),
              _viewRow(Icons.bar_chart, "Difficulty", problem['difficulty'], valueColor: _difficultyColor(problem['difficulty'])),
              _viewRow(Icons.description_outlined, "Description", problem['description']),
              if (problem['hint'] != null && problem['hint'].toString().isNotEmpty)
                _viewRow(Icons.lightbulb_outline, "Hint", problem['hint']),
              _viewRow(Icons.check_circle_outline, "Answer", problem['answer'], valueColor: Colors.green.shade700),
              _viewRow(Icons.upload_outlined, "Total Submissions", problem['total_submission'].toString()),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Problem Dialog ──
  void _showEditDialog(Map<String, dynamic> problem) {
    final titleController = TextEditingController(text: problem['title']);
    final descController = TextEditingController(text: problem['description']);
    final hintController = TextEditingController(text: problem['hint'] ?? '');
    final answerController = TextEditingController(text: problem['answer']);
    final subCategoryController = TextEditingController(text: problem['sub_category']);

    String selectedDifficulty = problem['difficulty'];
    String selectedMainCategory = problem['main_category'];

    final difficulties = ['Easy', 'Medium', 'Hard'];
    final mainCategories = ['Mathematical', 'Logical', 'Puzzle'];

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Edit Problem",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Title
                  _editLabel("Title"),
                  TextFormField(
                    controller: titleController,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    decoration: _inputDecoration("Problem title"),
                  ),
                  const SizedBox(height: 12),

                  // Main Category
                  _editLabel("Main Category"),
                  DropdownButtonFormField<String>(
                    value: mainCategories.contains(selectedMainCategory) ? selectedMainCategory : null,
                    items: mainCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedMainCategory = val!),
                    decoration: _inputDecoration("Select category"),
                  ),
                  const SizedBox(height: 12),

                  // Sub Category (free text input)
                  _editLabel("Sub Category"),
                  TextFormField(
                    controller: subCategoryController,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    decoration: _inputDecoration("e.g. Algebra, Sequences, Riddles..."),
                  ),
                  const SizedBox(height: 12),

                  // Difficulty
                  _editLabel("Difficulty"),
                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    items: difficulties
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedDifficulty = val!),
                    decoration: _inputDecoration("Select difficulty"),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  _editLabel("Description"),
                  TextFormField(
                    controller: descController,
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    decoration: _inputDecoration("Problem description"),
                  ),
                  const SizedBox(height: 12),

                  // Hint (optional)
                  _editLabel("Hint (optional)"),
                  TextFormField(
                    controller: hintController,
                    decoration: _inputDecoration("Add a hint"),
                  ),
                  const SizedBox(height: 12),

                  // Answer
                  _editLabel("Answer"),
                  TextFormField(
                    controller: answerController,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    decoration: _inputDecoration("Correct answer"),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(context);
                        _updateProblem(problem['id'], {
                          'title': titleController.text.trim(),
                          'main_category': selectedMainCategory,
                          'sub_category': subCategoryController.text.trim(),
                          'difficulty': selectedDifficulty,
                          'description': descController.text.trim(),
                          'hint': hintController.text.trim(),
                          'answer': answerController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete Confirm Dialog ──
  void _showDeleteDialog(Map<String, dynamic> problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Problem"),
        content: Text("Are you sure you want to delete \"${problem['title']}\"? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProblem(problem['id']);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _editLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Problems"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchProblems();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _problems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No problems found.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  itemCount: _problems.length,
                  itemBuilder: (context, index) {
                    final problem = _problems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _difficultyColor(problem['difficulty']).withOpacity(0.15),
                            child: Text(
                              problem['difficulty'][0], // E / M / H
                              style: TextStyle(
                                color: _difficultyColor(problem['difficulty']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            problem['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "${problem['main_category']} → ${problem['sub_category']}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                                tooltip: "View",
                                onPressed: () => _showViewDialog(Map<String, dynamic>.from(problem)),
                              ),
                              // Edit
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                tooltip: "Edit",
                                onPressed: () => _showEditDialog(Map<String, dynamic>.from(problem)),
                              ),
                              // Delete
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: "Delete",
                                onPressed: () => _showDeleteDialog(Map<String, dynamic>.from(problem)),
                              ),
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