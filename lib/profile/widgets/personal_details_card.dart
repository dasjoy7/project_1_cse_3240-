import 'package:flutter/material.dart';

class PersonalDetailsCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;

  const PersonalDetailsCard({super.key, required this.data, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Personal Details", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 28),
              )
            ],
          ),
          const Divider(height: 20),
          _detailRow(Icons.class_outlined, "Class", data['student_class']?.toString() ?? "N/A"),
          _detailRow(Icons.grid_view_rounded, "Category", data['category'] ?? "N/A"),
          _detailRow(Icons.school_outlined, "Institution", data['institution'] ?? "N/A"),
          _detailRow(Icons.public_rounded, "Country", data['country'] ?? "N/A"), // New
          _detailRow(Icons.map_outlined, "State/Division", data['state'] ?? "N/A"), // Updated to 'state'
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade300),
          const SizedBox(width: 12),
          Text("$label:", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87))),
        ],
      ),
    );
  }
}