import 'package:flutter/material.dart';

class ProfileIdentityCard extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final String userEmail;

  const ProfileIdentityCard({super.key, required this.profileData, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person_rounded, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(profileData['full_name'] ?? "User", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(userEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }
}

class PersonalDetailsCard extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback onEdit;

  const PersonalDetailsCard({super.key, required this.profileData, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Personal Details", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 28),
                onPressed: onEdit,
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(Icons.book_outlined, "Class", profileData['student_class']?.toString() ?? "N/A"),
          _buildDetailRow(Icons.grid_view_rounded, "Category", profileData['category']?.toString() ?? "N/A"),
          _buildDetailRow(Icons.map_outlined, "Division", profileData['division']?.toString() ?? "N/A"),
          _buildDetailRow(Icons.location_city_outlined, "District", profileData['district']?.toString() ?? "N/A"),
          _buildDetailRow(Icons.school_outlined, "Institution", profileData['institution']?.toString() ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey.shade200, size: 20),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }
}

class SecurityCard extends StatelessWidget {
  final VoidCallback onChangePassword;

  const SecurityCard({super.key, required this.onChangePassword});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Security", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
            ),
            title: const Text("Change Password", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            onTap: onChangePassword,
          ),
        ],
      ),
    );
  }
}

class LogoutCard extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutCard({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
        ),
        title: const Text("Logout", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        onTap: onLogout,
      ),
    );
  }
}