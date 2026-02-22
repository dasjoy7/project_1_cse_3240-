import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSearchDelegate extends SearchDelegate {
  final _supabase = Supabase.instance.client;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const Center(child: Text("Type a username"));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found with that username."));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final stats = user['user_profile_stats'] ?? {};

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(user['full_name']?[0] ?? "U"),
                ),
                title: Text(
                  user['full_name'] ?? "Unknown User",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Corrected: Using a Column instead of isThreeLine
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("@${user['username'] ?? 'unknown'}", 
                         style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                    Text(user['institution'] ?? 'No Institution', 
                         style: const TextStyle(fontSize: 12)),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStatGrid(stats),
                        const SizedBox(height: 16),
                        _buildDifficultyRow(stats),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Class: ${user['student_class'] ?? 'N/A'}", 
                                 style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                            Text("Category: ${user['category'] ?? 'N/A'}", 
                                 style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();

  // --- Logic for searching by username ---
  Future<List<Map<String, dynamic>>> _searchUsers(String searchTerm) async {
    final response = await _supabase
        .from('profile')
        .select('*, user_profile_stats(*)')
        .ilike('username', '%$searchTerm%') 
        .limit(10);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Widget _buildStatGrid(Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem("Total", stats['total_submission']),
        _statItem("Solved", stats['total_solved']),
        _statItem("Accepted", stats['accepted']),
        _statItem("Wrong", stats['wrong_answer']),
      ],
    );
  }

  Widget _buildDifficultyRow(Map<String, dynamic> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _pill("Easy: ${stats['easy_solved'] ?? 0}", Colors.green),
        _pill("Medium: ${stats['medium_solved'] ?? 0}", Colors.orange),
        _pill("Hard: ${stats['hard_solved'] ?? 0}", Colors.red),
      ],
    );
  }

  Widget _statItem(String label, dynamic value) {
    return Column(
      children: [
        Text(value?.toString() ?? "0", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}