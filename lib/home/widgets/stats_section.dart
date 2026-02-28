import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_1_cse_3240/friends/chat_page.dart';
import 'package:project_1_cse_3240/individual_profile_page.dart';
import '../home_models.dart';

class StatsSection extends StatelessWidget {
  final UserProfile profile;
  final int totalContests;
  final List<Friend> friends;

  const StatsSection({
    super.key,
    required this.profile,
    required this.friends,
    this.totalContests = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Row 1: Submissions stats ──
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _statItem(
                icon: Icons.send_outlined,
                color: const Color(0xFF1E88E5),
                label: 'Submissions',
                value: '${profile.totalSubmissions}',
              ),
              _vDivider(),
              _statItem(
                icon: Icons.check_circle_outline,
                color: const Color(0xFF43A047),
                label: 'Accepted',
                value: '${profile.accepted}',
              ),
              _vDivider(),
              _statItem(
                icon: Icons.cancel_outlined,
                color: const Color(0xFFE53935),
                label: 'Wrong',
                value: '${profile.wrong}',
              ),
            ],
          ),
        ),

        // ── Row 2: Friends + Contests ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _ClickableCard(
                  color: const Color(0xFF1E88E5),
                  icon: Icons.people_outline,
                  label: 'Friends',
                  value: '${friends.length}',
                  onTap: () => _showFriends(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClickableCard(
                  color: const Color(0xFFFFA726),
                  icon: Icons.emoji_events_outlined,
                  label: 'Contests',
                  value: '$totalContests',
                  onTap: () => _showContests(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: const Color(0xFFEEF0F5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  // ── Contests bottom sheet ──────────────────────────────────────────────────
  void _showContests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ContestsSheet(userId: profile.id),
    );
  }

  // ── Friends bottom sheet ───────────────────────────────────────────────────
  void _showFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'Friends',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${friends.length}',
                      style: const TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            friends.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No friends yet',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: friends.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFEEF0F5)),
                      itemBuilder: (ctx, i) {
                        final f = friends[i];
                        const colors = [
                          Color(0xFF1E88E5),
                          Color(0xFF43A047),
                          Color(0xFFFFA726),
                          Color(0xFFE53935),
                          Color(0xFF8E24AA),
                        ];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    IndividualProfilePage(userId: f.id),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: colors[i % colors.length],
                                  child: Text(
                                    f.username.isNotEmpty
                                        ? f.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '@${f.username}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        f.category,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          receiverId: f.id,
                                          receiverName: f.username,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFF1E88E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Contests bottom sheet widget ───────────────────────────────────────────────

class _ContestsSheet extends StatefulWidget {
  final String userId;
  const _ContestsSheet({required this.userId});

  @override
  State<_ContestsSheet> createState() => _ContestsSheetState();
}

class _ContestsSheetState extends State<_ContestsSheet> {
  List<Map<String, dynamic>> _contests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Fetch contests the user registered for, joined with contest details
      final rows = await Supabase.instance.client
          .from('contest_registrations')
          .select('registered_at, contests(id, title, date, start_time, category)')
          .eq('user_id', widget.userId)
          .order('registered_at', ascending: false);

      setState(() {
        _contests = List<Map<String, dynamic>>.from(rows);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  'Contests Participated',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_contests.length}',
                    style: const TextStyle(
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Body
          _loading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : _contests.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No contests yet',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _contests.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEF0F5)),
                        itemBuilder: (_, i) {
                          final contest = _contests[i]['contests'];
                          final title = contest?['title'] ?? 'Unknown';
                          final date = contest?['date'] ?? '';
                          final time = contest?['start_time'] ?? '';
                          final category = contest?['category'] ?? '';

                          // Determine if completed
                          bool isCompleted = false;
                          try {
                            isCompleted = DateTime.now()
                                .isAfter(DateTime.parse('$date $time'));
                          } catch (_) {}

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.grey.shade100
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events_outlined,
                                    size: 20,
                                    color: isCompleted
                                        ? Colors.grey
                                        : const Color(0xFFFFA726),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$date  •  $category',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.grey.shade100
                                        : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isCompleted ? 'Done' : 'Upcoming',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? Colors.grey.shade600
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

// ── Shared clickable card ──────────────────────────────────────────────────────

class _ClickableCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ClickableCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}