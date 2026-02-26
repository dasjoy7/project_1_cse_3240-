import 'package:flutter/material.dart';

class BlogDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  const BlogDetailPage({super.key, required this.post});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.parse(dateStr).toLocal();
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        leading: const BackButton(),
        title: const Text('Article', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(post['category'] ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              post['title'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), height: 1.3),
            ),
            const SizedBox(height: 16),

            // Author row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1E88E5).withOpacity(0.12),
                  child: Text(
                    (post['author_name'] ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['author_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                    Text(
                      _formatDate(post['approved_at'] ?? post['created_at']),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEF0F5)),
            const SizedBox(height: 20),

            // Content
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D), height: 1.8),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}