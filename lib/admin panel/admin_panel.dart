import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/admin%20panel/manage_problem_page.dart';
import 'package:project_1_cse_3240/admin%20panel/manage_contests_page.dart';
import 'package:project_1_cse_3240/admin%20panel/view_all_users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_problem_page.dart';
import 'add_contest_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // clears entire navigation stack
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, // hides back button for admin
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
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text("Add Problem"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProblemPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text("Manage Problems"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageProblemsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Add Contest"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContestPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_calendar_outlined),
            title: const Text("Manage Contests"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageContestsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed_outlined),
            title: const Text("Manage Blog Posts"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageContestsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed_outlined),
            title: const Text("View all users"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewAllUsersPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feed_outlined),
            title: const Text("Announcements"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageContestsPage(),
                ),
              );
            },
          ),

          const Divider(),

          // Logout tile at the bottom
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}