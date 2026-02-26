import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IndividualProfilePage extends StatefulWidget {
  final String userId;

  const IndividualProfilePage({super.key, required this.userId});

  @override
  State<IndividualProfilePage> createState() => _IndividualProfilePageState();
}

class _IndividualProfilePageState extends State<IndividualProfilePage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _supabase
          .from('profile')
          .select()
          .eq('id', widget.userId)
          .single();
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _profile != null ? '@${_profile!['username']}' : 'Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildStatsRow(),
                        const SizedBox(height: 10),
                        _buildSolvedBreakdown(),
                        const SizedBox(height: 10),
                        _buildInfoSection('Personal', [
                          _InfoRow(label: 'Full Name', value: _profile!['full_name'] ?? '-'),
                          _InfoRow(label: 'Class', value: 'Class ${_profile!['student_class']}'),
                          _InfoRow(label: 'Category', value: _profile!['category'] ?? '-'),
                        ]),
                        _buildInfoSection('Location', [
                          _InfoRow(label: 'Division', value: _profile!['division'] ?? '-'),
                          _InfoRow(label: 'District', value: _profile!['district'] ?? '-'),
                          _InfoRow(label: 'Institution', value: _profile!['institution'] ?? '-'),
                        ]),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Error State ──
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Header with gradient ──
  Widget _buildHeader() {
    final p = _profile!;
    final name = (p['full_name'] ?? '') as String;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${p['username']} · ${p['category'] ?? ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Rating + Submissions badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _headerBadge(Icons.star_rounded, 'Rating', '${p['rating'] ?? 0}', Colors.amber),
              const SizedBox(width: 10),
              _headerBadge(Icons.upload_rounded, 'Submissions', '${p['total_submissions'] ?? 0}', Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Row (Accepted / Wrong) ──
  Widget _buildStatsRow() {
    final p = _profile!;
    final accepted = p['accepted'] ?? 0;
    final wrong = p['wrong'] ?? 0;
    final total = accepted + wrong;
    final rate = total > 0 ? (accepted / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submission Stats',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCell('Accepted', '$accepted', Colors.green),
              _verticalDivider(),
              _statCell('Wrong', '$wrong', Colors.red),
              _verticalDivider(),
              _statCell('Accuracy', '$rate%', const Color(0xFF1E88E5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFEEF0F5));
  }

  // ── Solved Breakdown (Easy / Medium / Hard) ──
  Widget _buildSolvedBreakdown() {
    final p = _profile!;
    final easy = p['easy_solve'] ?? 0;
    final medium = p['medium_solve'] ?? 0;
    final hard = p['hard_solve'] ?? 0;
    final total = easy + medium + hard;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Problems Solved',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5)),
              ),
              Text(
                '$total Total',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          const SizedBox(height: 16),

          // Progress bars
          _difficultyBar('Easy', easy, total, Colors.green),
          const SizedBox(height: 12),
          _difficultyBar('Medium', medium, total, Colors.orange),
          const SizedBox(height: 12),
          _difficultyBar('Hard', hard, total, Colors.red),
        ],
      ),
    );
  }

  Widget _difficultyBar(String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ── Info Section ──
  Widget _buildInfoSection(String title, List<_InfoRow> rows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final row = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(row.label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      const Spacer(),
                      Text(
                        row.value,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFEEF0F5), indent: 16, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow({required this.label, required this.value});
}