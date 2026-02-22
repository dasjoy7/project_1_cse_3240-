import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/widgets/settings/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'drawer_service.dart';
import 'package:project_1_cse_3240/widgets/settings/settings_page.dart';
import 'package:project_1_cse_3240/features/auth/pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onMenuClick;

  const AppDrawer({super.key, this.onMenuClick});

  @override
  Widget build(BuildContext context) {
    final drawerService = DrawerService();
    final menuItems = drawerService.getNavigationItems();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32))),
      child: Column(
        children: [
          // --- DRAWER HEADER ---
          FutureBuilder<Map<String, dynamic>>(
            future: drawerService.getDrawerData(),
            builder: (context, snapshot) {
              final name = snapshot.data?['name'] ?? "Loading...";
              final studentClass = snapshot.data?['class'] ?? "...";
              return InkWell(
                onTap: () { Navigator.pop(context); onMenuClick?.call(4); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 16, bottom: 30),
                  decoration: BoxDecoration(color: Colors.blue.shade600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 16),
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("Class $studentClass • Level 1", style: TextStyle(color: Colors.blue.shade100, fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // --- NAVIGATION ITEMS ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(context, item.icon, item.title, hasBadge: item.hasBadge, color: item.color, 
                    onTap: () => onMenuClick?.call(item.index!));
              },
            ),
          ),

          const Divider(),
          
          // --- SETTINGS BUTTON ---
          _buildMenuItem(context, Icons.settings_outlined, "Settings", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          }),
          
          // --- LOGOUT BUTTON WITH CONFIRMATION ---
          _buildMenuItem(context, Icons.logout_rounded, "Logout", color: Colors.redAccent, isLogout: true, 
              onTap: () => _showLogoutConfirmation(context)),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // --- LOGOUT CONFIRMATION DIALOG ---
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out of your account?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close Dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginPage()), 
                    (_) => false
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- UI HELPERS ---
  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const CircleAvatar(radius: 34, backgroundColor: Color(0xFFE3F2FD), 
          child: Icon(Icons.person_rounded, color: Colors.blue, size: 40)),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, 
      {bool hasBadge = false, Color? color, bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: () {
        // Only close the drawer immediately if it's NOT the logout button
        if (!isLogout && title != "Settings") Navigator.pop(context);
        onTap?.call();
      },
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: hasBadge ? _buildBadge() : null,
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(20)),
      child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}