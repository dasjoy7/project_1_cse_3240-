import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitBlogPage extends StatefulWidget {
  const SubmitBlogPage({super.key});

  @override
  State<SubmitBlogPage> createState() => _SubmitBlogPageState();
}

class _SubmitBlogPageState extends State<SubmitBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAuthorName();
  }

  Future<void> _loadAuthorName() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('profile')
          .select('full_name')
          .eq('id', userId)
          .single();
      _authorCtrl.text = data['full_name'] ?? '';
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('blog_posts').insert({
        'author_id': userId,
        'author_name': _authorCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post submitted! Awaiting admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Write Article', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your article will be reviewed by an admin before being published.',
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title + Author
              _buildCard([
                _buildLabel('Title'),
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  decoration: _inputDecor('Enter your article title'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                _buildLabel('Author Name'),
                TextFormField(
                  controller: _authorCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  decoration: _inputDecor('Your name as it will appear'),
                ),
              ]),

              const SizedBox(height: 12),

              // Category as text input
              _buildCard([
                _buildLabel('Category'),
                TextFormField(
                  controller: _categoryCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  decoration: _inputDecor('e.g. Algebra, Geometry, Number Theory...'),
                  textCapitalization: TextCapitalization.words,
                ),
              ]),

              const SizedBox(height: 12),

              // Content
              _buildCard([
                _buildLabel('Article Content'),
                const SizedBox(height: 4),
                Text(
                  'Write your full article, explanation, or research here.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contentCtrl,
                  maxLines: 14,
                  validator: (v) =>
                      v == null || v.trim().length < 50 ? 'Content must be at least 50 characters' : null,
                  decoration: _inputDecor('Start writing...'),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text(
                    'Submit for Review',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E88E5)),
        ),
      );

  InputDecoration _inputDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}