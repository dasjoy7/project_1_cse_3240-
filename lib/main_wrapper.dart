import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/admin%20panel/admin_panel.dart';
import 'package:project_1_cse_3240/contest/contest_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';
import 'package:project_1_cse_3240/home/home_page.dart';
import 'package:project_1_cse_3240/leaderboard/leaderboard_page.dart';
import 'package:project_1_cse_3240/problem/problem_page.dart';
import 'package:project_1_cse_3240/profile/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const ProblemPage(),
    const LeaderboardPage(),
    const ContestPage(),
    const ProfilePage(),
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Math Arena"),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E88E5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF1E88E5),
                      size: 35,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Math Athlete",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Arena"),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),

            // Admin Panel option added here
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Admin Panel"),
              onTap: () {
                // Navigate to the Admin Panel screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanel(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to exit?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ) ??
                    false;

                if (confirm) {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                          (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.jumpToPage(index); // Navigate to selected page
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1E88E5),
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: "Problems",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                activeIcon: Icon(Icons.leaderboard),
                label: "Rank",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: "Contest",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}