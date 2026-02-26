import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'submit_blog_page.dart';
import 'blog_detail_page.dart';
import 'my_blogs_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPosts();
  }

  // Dynamically load distinct categories from approved posts
  Future<void> _fetchCategories() async {
    try {
      final data = await _supabase
          .from('blog_posts')
          .select('category')
          .eq('status', 'approved');

      final cats = (data as List)
          .map((e) => e['category'].toString())
          .toSet()
          .toList()
        ..sort();

      setState(() => _categories = ['All', ...cats]);
    } catch (_) {}
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      late List data;

      if (_selectedCategory == 'All') {
        data = await _supabase
            .from('blog_posts')
            .select()
            .eq('status', 'approved')
            .order('approved_at', ascending: false);
      } else {
        data = await _supabase
            .from('blog_posts')
            .select()
            .eq('status', 'approved')
            .eq('category', _selectedCategory)
            .order('approved_at', ascending: false);
      }

      setState(() {
        _posts = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _fetchCategories();
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Math Blog',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Articles & Research by Students',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyBlogsPage()),
                          ),
                          icon: const Icon(Icons.history_outlined, size: 16),
                          label: const Text('My Posts', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E88E5)),
                        ),
                      ],
                    ),

                    // Category chips — shown only if there are categories
                    if (_categories.length > 1) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = _categories[i];
                            final selected = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = cat);
                                _fetchPosts();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFF1E88E5) : const Color(0xFFF4F6FB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? const Color(0xFF1E88E5) : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Posts ──
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_posts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No posts yet', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Be the first to write!', style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BlogCard(
                      post: _posts[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BlogDetailPage(post: _posts[index])),
                      ),
                    ),
                    childCount: _posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final submitted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const SubmitBlogPage()),
          );
          if (submitted == true) _refresh();
        },
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Write', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Blog Card ──
class _BlogCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;

  const _BlogCard({required this.post, required this.onTap});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.parse(dateStr).toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  post['category'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                post['title'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Preview
              Text(
                post['content'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEF0F5)),
              const SizedBox(height: 10),

              // Author + Date
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                    child: Text(
                      (post['author_name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post['author_name'] ?? '',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(post['approved_at'] ?? post['created_at']),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}