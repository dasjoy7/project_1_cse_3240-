import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/admin%20panel/manage_problem_page.dart';
import 'package:project_1_cse_3240/admin%20panel/manage_contests_page.dart';
import 'package:project_1_cse_3240/admin%20panel/view_all_users.dart';
import 'package:project_1_cse_3240/admin%20panel/admin_manage_blogs_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_problem_page.dart';
import 'add_contest_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _pendingBlogCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPendingCount();
  }

  Future<void> _fetchPendingCount() async {
    try {
      final data = await Supabase.instance.client
          .from('blog_posts')
          .select('id')
          .eq('status', 'pending');
      setState(() => _pendingBlogCount = (data as List).length);
    } catch (_) {}
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1E88E5),
    int badgeCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)) : null,
        trailing: badgeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Admin Panel", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          _buildSectionHeader('PROBLEMS'),
          _buildTile(
            icon: Icons.add_box_outlined,
            title: 'Add Problem',
            subtitle: 'Create a new problem',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProblemPage())),
          ),
          _buildTile(
            icon: Icons.tune_outlined,
            title: 'Manage Problems',
            subtitle: 'View, edit or delete problems',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageProblemsPage())),
          ),

          _buildSectionHeader('CONTESTS'),
          _buildTile(
            icon: Icons.emoji_events_outlined,
            title: 'Add Contest',
            subtitle: 'Create a new contest',
            iconColor: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddContestPage())),
          ),
          _buildTile(
            icon: Icons.edit_calendar_outlined,
            title: 'Manage Contests',
            subtitle: 'Edit or delete contests',
            iconColor: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageContestsPage())),
          ),

          _buildSectionHeader('BLOG'),
          _buildTile(
            icon: Icons.article_outlined,
            title: 'Manage Blog Posts',
            subtitle: 'Approve or reject submissions',
            iconColor: Colors.teal,
            badgeCount: _pendingBlogCount,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageBlogsPage()));
              _fetchPendingCount(); // refresh badge on return
            },
          ),

          _buildSectionHeader('USERS'),
          _buildTile(
            icon: Icons.people_outline,
            title: 'View All Users',
            subtitle: 'Message or terminate accounts',
            iconColor: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewAllUsersPage())),
          ),
          _buildTile(
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            subtitle: 'Send announcements to users',
            iconColor: Colors.purple,
            onTap: () {}, // TODO: connect to announcements page
          ),

          const Divider(height: 32, indent: 16, endIndent: 16),

          // Logout
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: Colors.red, size: 22),
              ),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _handleLogout(context),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}