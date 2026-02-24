import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteProblemPage extends StatefulWidget {
  const DeleteProblemPage({super.key});

  @override
  _DeleteProblemPageState createState() => _DeleteProblemPageState();
}

class _DeleteProblemPageState extends State<DeleteProblemPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _problems = [];
  bool _isLoading = true;

  Future<void> _fetchProblems() async {
    try {
      final data = await _supabase
          .from('problems')
          .select()
          .order('created_at');
      setState(() {
        _problems = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching problems: $e')),
      );
    }
  }

  Future<void> _deleteProblem(String problemId) async {
    try {
      await _supabase
          .from('problems')
          .delete()
          .eq('id', problemId); // ✅ no .single(), no .execute()

      setState(() {
        _problems.removeWhere((problem) => problem['id'] == problemId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting problem: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProblems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Problem"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _problems.isEmpty
          ? const Center(child: Text('No problems found.'))
          : ListView.builder(
        itemCount: _problems.length,
        itemBuilder: (context, index) {
          final problem = _problems[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text(problem['title']),
              subtitle: Text('Category: ${problem['main_category']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Problem"),
                      content: const Text(
                          "Are you sure you want to delete this problem?"),
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
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}