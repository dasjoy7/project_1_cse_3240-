import 'package:flutter/material.dart';
import '../home_models.dart';

class BadgesSection extends StatelessWidget {
  final List<BadgeInfo> badges;

  const BadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final unlocked = badges.where((b) => b.unlocked).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Badges',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E)),
              ),
              const Spacer(),
              Text(
                '$unlocked / ${badges.length} unlocked',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable row of badges — no overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: badges
                  .map((b) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _BadgeTile(badge: b),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: unlocked / badges.length,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEF0F5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1E88E5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeInfo badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(badge.name),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.description),
              const SizedBox(height: 8),
              Text('Required rating: ${badge.requiredRating}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              if (!badge.unlocked) ...[
                const SizedBox(height: 8),
                Text('🔒 Locked',
                    style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      ),
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.unlocked
                      ? const Color(0xFF1E88E5)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: badge.unlocked
                    ? [
                  BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.25),
                      blurRadius: 8)
                ]
                    : null,
              ),
              child: Center(
                child: badge.unlocked
                    ? Text(badge.emoji, style: const TextStyle(fontSize: 22))
                    : const Icon(Icons.lock_outline,
                    size: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 9,
                color: badge.unlocked
                    ? const Color(0xFF1E88E5)
                    : Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}