import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blog_detail_page.dart';

class MyBlogsPage extends StatefulWidget {
  const MyBlogsPage({super.key});

  @override
  State<MyBlogsPage> createState() => _MyBlogsPageState();
}

class _MyBlogsPageState extends State<MyBlogsPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyPosts();
  }

  Future<void> _fetchMyPosts() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('blog_posts')
          .select()
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _posts = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.hourglass_empty_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default: return 'Pending Review';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.parse(dateStr).toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('My Articles', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_off_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("You haven't submitted any articles yet.", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMyPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final status = post['status'] ?? 'pending';
                      final isApproved = status == 'approved';

                      return GestureDetector(
                        onTap: isApproved
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlogDetailPage(post: post)))
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E88E5).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(post['category'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
                                  ),
                                  const Spacer(),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                                        const SizedBox(width: 4),
                                        Text(_statusLabel(status), style: TextStyle(fontSize: 10, color: _statusColor(status), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text(_formatDate(post['created_at']), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),

                              // Admin note if rejected
                              if (status == 'rejected' && post['admin_note'] != null && post['admin_note'].toString().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade100),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.feedback_outlined, size: 14, color: Colors.red.shade400),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Admin note: ${post['admin_note']}',
                                          style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}