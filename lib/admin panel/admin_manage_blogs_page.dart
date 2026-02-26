import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManageBlogsPage extends StatefulWidget {
  const AdminManageBlogsPage({super.key});

  @override
  State<AdminManageBlogsPage> createState() => _AdminManageBlogsPageState();
}

class _AdminManageBlogsPageState extends State<AdminManageBlogsPage>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _rejected = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('blog_posts')
          .select()
          .order('created_at', ascending: false);

      final all = List<Map<String, dynamic>>.from(data);
      setState(() {
        _pending = all.where((p) => p['status'] == 'pending').toList();
        _approved = all.where((p) => p['status'] == 'approved').toList();
        _rejected = all.where((p) => p['status'] == 'rejected').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error fetching posts: $e', isError: true);
    }
  }

  Future<void> _approve(Map<String, dynamic> post) async {
    try {
      await _supabase.from('blog_posts').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
        'admin_note': null,
      }).eq('id', post['id']);
      _showSnackBar('Post approved and published!');
      await _fetchAll();
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _reject(Map<String, dynamic> post) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Post', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rejecting: "${post['title']}"', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 14),
            const Text('Admin note (optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('blog_posts').update({
          'status': 'rejected',
          'admin_note': noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        }).eq('id', post['id']);
        _showSnackBar('Post rejected.');
        await _fetchAll();
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _delete(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Permanently delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _supabase.from('blog_posts').delete().eq('id', postId);
        _showSnackBar('Post deleted.');
        await _fetchAll();
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  void _showFullPost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),
              _infoRow('Category', post['category'] ?? ''),
              _infoRow('Author', post['author_name'] ?? ''),
              _infoRow('Submitted', _formatDate(post['created_at'])),
              const SizedBox(height: 12),
              Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.6)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1E88E5))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.parse(dateStr).toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildPostCard(Map<String, dynamic> post, {bool showActions = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF1E88E5).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(post['category'] ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Text(_formatDate(post['created_at']), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 8),
            Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('By ${post['author_name'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 10),
            // Action row
            Row(
              children: [
                // View full post
                OutlinedButton.icon(
                  onPressed: () => _showFullPost(post),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('Read', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approve(post),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _reject(post),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Reject', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _delete(post['id']),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(List<Map<String, dynamic>> posts, {bool showActions = false}) {
    if (posts.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text('No posts here', style: TextStyle(color: Colors.grey.shade400)),
        ],
      ));
    }
    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, i) => _buildPostCard(posts[i], showActions: showActions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Manage Blog Posts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAll),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Approved (${_approved.length})'),
            Tab(text: 'Rejected (${_rejected.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTab(_pending, showActions: true),
                _buildTab(_approved),
                _buildTab(_rejected),
              ],
            ),
    );
  }
}