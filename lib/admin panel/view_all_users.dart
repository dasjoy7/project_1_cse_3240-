import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAllUsersPage extends StatefulWidget {
  const ViewAllUsersPage({super.key});

  @override
  State<ViewAllUsersPage> createState() => _ViewAllUsersPageState();
}

class _ViewAllUsersPageState extends State<ViewAllUsersPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await _supabase
          .from('profile')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _users = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching users: $e', isError: true);
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _users.where((u) {
        return u['full_name'].toString().toLowerCase().contains(query) ||
            u['username'].toString().toLowerCase().contains(query) ||
            u['email'].toString().toLowerCase().contains(query) ||
            u['institution'].toString().toLowerCase().contains(query);
      }).toList();
    });
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

  // ── View Profile Dialog ──
  void _showProfileDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Name
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF1E88E5).withOpacity(0.15),
                    child: Text(
                      user['full_name'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@${user['username']}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip("Rating", user['rating']?.toString() ?? '0', Colors.blue),
                  _statChip("Accepted", user['accepted']?.toString() ?? '0', Colors.green),
                  _statChip("Wrong", user['wrong']?.toString() ?? '0', Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip("Easy", user['easy_solve']?.toString() ?? '0', Colors.green.shade300),
                  _statChip("Medium", user['medium_solve']?.toString() ?? '0', Colors.orange),
                  _statChip("Hard", user['hard_solve']?.toString() ?? '0', Colors.red.shade700),
                ],
              ),
              const Divider(height: 24),

              // Info
              _infoRow(Icons.email_outlined, "Email", user['email']),
              _infoRow(Icons.school_outlined, "Institution", user['institution']),
              _infoRow(Icons.class_outlined, "Class", user['student_class'].toString()),
              _infoRow(Icons.category_outlined, "Category", user['category']),
              _infoRow(Icons.location_city_outlined, "Division", user['division']),
              _infoRow(Icons.map_outlined, "District", user['district']),
              _infoRow(Icons.upload_outlined, "Total Submissions", user['total_submissions']?.toString() ?? '0'),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showMessageDialog(user);
                      },
                      icon: const Icon(Icons.message_outlined, color: Color(0xFF1E88E5)),
                      label: const Text("Message", style: TextStyle(color: Color(0xFF1E88E5))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E88E5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showTerminateDialog(user);
                      },
                      icon: const Icon(Icons.block),
                      label: const Text("Terminate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Message Dialog ──
  void _showMessageDialog(Map<String, dynamic> user) {
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.message_outlined, color: Color(0xFF1E88E5)),
              const SizedBox(width: 8),
              Expanded(child: Text("Message @${user['username']}", style: const TextStyle(fontSize: 16))),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: messageController,
              maxLines: 5,
              validator: (v) => v == null || v.trim().isEmpty ? "Message cannot be empty" : null,
              decoration: InputDecoration(
                hintText: "Write your message here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: isSending
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSending = true);
                      try {
                        // Insert message into a 'messages' table
                        // Adjust this to however your messaging system works
                        await _supabase.from('messages').insert({
                          'receiver_id': user['id'],
                          'receiver_username': user['username'],
                          'message': messageController.text.trim(),
                          'sent_at': DateTime.now().toIso8601String(),
                          'from': 'Admin',
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          _showSnackBar('Message sent to @${user['username']}');
                        }
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        _showSnackBar('Failed to send message: $e', isError: true);
                      }
                    },
              icon: isSending
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label: const Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Terminate Dialog ──
  void _showTerminateDialog(Map<String, dynamic> user) {
    bool isTerminating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Terminate Account", style: TextStyle(color: Colors.red)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                const TextSpan(text: "You are about to permanently delete the account of "),
                TextSpan(
                  text: "@${user['username']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ".\n\nThis will remove all their data and cannot be undone. Are you sure?",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: isTerminating
                  ? null
                  : () async {
                      setDialogState(() => isTerminating = true);
                      try {
                        // Deletes from profile table — cascades to auth.users via FK
                        await _supabase
                            .from('profile')
                            .delete()
                            .eq('id', user['id']);

                        if (context.mounted) {
                          Navigator.pop(context);
                          _showSnackBar('Account @${user['username']} has been terminated.');
                          await _fetchUsers();
                        }
                      } catch (e) {
                        setDialogState(() => isTerminating = false);
                        _showSnackBar('Failed to terminate account: $e', isError: true);
                      }
                    },
              icon: isTerminating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.block),
              label: const Text("Terminate"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, username, email, institution...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // User count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${_filtered.length} user${_filtered.length == 1 ? '' : 's'} found",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
                            SizedBox(height: 12),
                            Text("No users found.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final user = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.15),
                                child: Text(
                                  user['full_name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                user['full_name'],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${user['username']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(user['institution'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Message
                                  IconButton(
                                    icon: const Icon(Icons.message_outlined, color: Color(0xFF1E88E5)),
                                    tooltip: "Message",
                                    onPressed: () => _showMessageDialog(Map<String, dynamic>.from(user)),
                                  ),
                                  // View
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, color: Colors.orange),
                                    tooltip: "View Profile",
                                    onPressed: () => _showProfileDialog(Map<String, dynamic>.from(user)),
                                  ),
                                  // Terminate
                                  IconButton(
                                    icon: const Icon(Icons.block, color: Colors.red),
                                    tooltip: "Terminate",
                                    onPressed: () => _showTerminateDialog(Map<String, dynamic>.from(user)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}