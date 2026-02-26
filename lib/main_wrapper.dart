import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/ai/ask_ai_page.dart';
import 'package:project_1_cse_3240/blog%20page/blog_page.dart';
import 'package:project_1_cse_3240/contest/contest_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';
import 'package:project_1_cse_3240/home/home_page.dart';
import 'package:project_1_cse_3240/leaderboard/leaderboard_page.dart';
import 'package:project_1_cse_3240/problem/problem_page.dart';
import 'package:project_1_cse_3240/profile/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'friends/find_friends_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  String _username = '';
  String _fullName = '';

  final List<Widget> _screens = [
    const HomePage(),
    const ProblemPage(),
    const LeaderboardPage(),
    const ContestPage(),
    const BlogPage()
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('profile')
          .select('username, full_name')
          .eq('id', userId)
          .single();
      setState(() {
        _username = data['username'] ?? '';
        _fullName = data['full_name'] ?? '';
      });
    } catch (_) {}
  }

  void _navigateToProfile() {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              "My Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: const BackButton(),
          ),
          body: const ProfilePage(),
        ),
      ),
    );
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
            // ── Clickable Drawer Header → Profile ──
            InkWell(
              onTap: _navigateToProfile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                decoration: const BoxDecoration(color: Color(0xFF1E88E5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF1E88E5),
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _fullName.isNotEmpty ? _fullName : 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_username.isNotEmpty)
                      Text(
                        '@$_username',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Text(
                          "View Profile",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white60, size: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Arena"),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Friends"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindFriendsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text("AI Tutor"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AskAIPage(),
                  ),
                );
              },
            ),
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
                          builder: (context) => const LoginPage()),
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
        onPageChanged: (index) => setState(() => _selectedIndex = index),
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
              setState(() => _selectedIndex = index);
              _pageController.jumpToPage(index);
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
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: "Blog",
              ),
            ],
          ),
        ),
      ),
    );
  }
}