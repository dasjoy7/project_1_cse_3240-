import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/home/home_page.dart';
import 'package:project_1_cse_3240/profile/screens/profile_page.dart';
import 'package:project_1_cse_3240/problems/screens/problem_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:project_1_cse_3240/home/home_page.dart';
import 'package:project_1_cse_3240/leaderboard_page.dart';
import 'package:project_1_cse_3240/contest/contest_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';
import 'package:project_1_cse_3240/widgets/app_drawer.dart';
import 'package:project_1_cse_3240/widgets/user_search_delegate.dart'; 

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const ProblemListPage(),
    const LeaderboardPage(),
    const ContestPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true,
      appBar: AppBar(
        title: const Text(
          "Math Arena",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search by username',
            onPressed: () {
              showSearch(
                context: context,
                delegate: UserSearchDelegate(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        onMenuClick: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
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
            onTap: (i) => setState(() => _selectedIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1E88E5),
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "Problems"),
              BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), activeIcon: Icon(Icons.leaderboard), label: "Rank"),
              BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), activeIcon: Icon(Icons.emoji_events), label: "Contest"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}