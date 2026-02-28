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

// ── Color palette ──────────────────────────────────────────────────────────────
// Soft sky blue primary instead of harsh #1E88E5
const kPrimary     = Color(0xFF4A90D9);   // calm sky blue
const kPrimaryDeep = Color(0xFF3574C4);   // slightly deeper for gradients
const kSurface     = Color(0xFFF7F9FC);   // near-white background
const kCardWhite   = Color(0xFFFFFFFF);
const kTextDark    = Color(0xFF1E2A3B);
const kTextMid     = Color(0xFF5A6A7E);
const kTextLight   = Color(0xFF8FA0B4);
// ───────────────────────────────────────────────────────────────────────────────

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
    const BlogPage(),
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
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: kSurface,
          appBar: _buildAppBar("My Profile"),
          body: const ProfilePage(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: kCardWhite,
      foregroundColor: kTextDark,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: kTextDark,
          letterSpacing: 0.2,
        ),
      ),
      leading: const BackButton(color: kTextDark),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFEAEFF6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,

      // ── AppBar ────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kCardWhite,
        foregroundColor: kTextDark,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kPrimaryDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.functions_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              "Math Arena",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: kTextDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEAEFF6)),
        ),
        iconTheme: const IconThemeData(color: kTextDark),
      ),

      // ── Drawer ────────────────────────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: kCardWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: _navigateToProfile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, kPrimaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 1.5),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _fullName.isNotEmpty ? _fullName : 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$_username',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "View Profile",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.65), size: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    label: "About Arena",
                    onTap: () => Navigator.pop(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Divider(color: Color(0xFFEAEFF6), height: 1),
                  ),
                  _drawerItem(
                    icon: Icons.people_outline_rounded,
                    label: "Friends",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FindFriendsPage(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.smart_toy_outlined,
                    label: "AI Tutor",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AskAIPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFFFF0F0),
                leading: const Icon(Icons.logout_rounded,
                    color: Color(0xFFE05555), size: 20),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFFE05555),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () async {
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text("Logout",
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                          content:
                              const Text("Are you sure you want to exit?"),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: Text("Cancel",
                                  style: TextStyle(color: kTextMid)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text(
                                "Logout",
                                style:
                                    TextStyle(color: Color(0xFFE05555)),
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
            ),
          ],
        ),
      ),

      // ── Body ─────────────────────────────────────────────────────────────────
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: _screens,
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Container(
          decoration: BoxDecoration(
            color: kCardWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90D9).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                _pageController.jumpToPage(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: kCardWhite,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextLight,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment_rounded),
                  label: "Problems",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_outlined),
                  activeIcon: Icon(Icons.leaderboard_rounded),
                  label: "Rank",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events_rounded),
                  label: "Contest",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: "Blog",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: drawer list tile ──────────────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimary, size: 19),
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: kTextDark,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: kTextLight, size: 18),
        onTap: onTap,
      ),
    );
  }
}