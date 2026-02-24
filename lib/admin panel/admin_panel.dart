import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/admin%20panel/delete_problem_page.dart';
import 'add_problem_page.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text("Add Problem"),
            onTap: () {
              // Navigate to Add Problem page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProblemPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text("Delete Problem"),
            onTap: () {
              // Navigate to Add Contest page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteProblemPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Blog Request"),
            // onTap: () {
            //   // Navigate to Blog Request page
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       // builder: (context) => const BlogRequestPage(),
            //     ),
            //   );
            // },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text("Assign Admin"),
            // onTap: () {
            //   // Navigate to Assign Admin page
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       // builder: (context) => const AssignAdminPage(),
            //     ),
            //   );
            // },
          ),
        ],
      ),
    );
  }
}