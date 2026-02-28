import 'package:flutter/material.dart';

// ── Theme constants ────────────────────────────────────────────────────────
const _kPrimary     = Color(0xFF4A90D9);
const _kPrimaryDeep = Color(0xFF3574C4);
const _kSurface     = Color(0xFFF7F9FC);
const _kCardWhite   = Color(0xFFFFFFFF);
const _kTextDark    = Color(0xFF1E2A3B);
const _kTextMid     = Color(0xFF5A6A7E);
const _kTextLight   = Color(0xFF8FA0B4);
const _kBorder      = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardWhite,
        foregroundColor: _kTextDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'User Guide',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _kTextDark,
          ),
        ),
        leading: const BackButton(color: _kTextDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimaryDeep, _kPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome to Mathletics!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Here\'s everything you need to know to get started and make the most of the app.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text('📘', style: TextStyle(fontSize: 40)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _GuideSection(
            emoji: '🏠',
            color: const Color(0xFF4A90D9),
            title: 'Home',
            steps: const [
              'The Home tab gives you a quick overview of your progress and recent activity.',
              'Check your stats at a glance — problems solved, accuracy rate, and current rating.',
              'Use the Home screen to pick up where you left off quickly.',
            ],
          ),
          _GuideSection(
            emoji: '📝',
            color: const Color(0xFF3DAA6E),
            title: 'Problems',
            steps: const [
              'Browse problems across three categories: Mathematical, Logical, and Puzzle.',
              'Tap the filter icon (top right) to narrow down by difficulty (Easy / Medium / Hard) or sub-category.',
              'Tap any problem card to open it, read the description, and optionally expand the Hint.',
              'Type your answer in the text box and tap Submit Answer.',
              'Green ✓ means correct — your stats update automatically. Red ✗ means try again!',
              'Your submission history is shown at the bottom of each problem page.',
            ],
          ),
          _GuideSection(
            emoji: '🏆',
            color: const Color(0xFFE89B2A),
            title: 'Leaderboard',
            steps: const [
              'See how you rank against other users in real time.',
              'The top 3 players are shown on a special podium — aim for the crown! 👑',
              'Use the filter (top right) to narrow rankings by Category, Division, or District.',
              'Tap any player\'s card to view their full profile.',
              'Your own entry is highlighted in blue so you can find it quickly.',
            ],
          ),
          _GuideSection(
            emoji: '🎯',
            color: const Color(0xFFE05555),
            title: 'Contests',
            steps: const [
              'Contests are timed competitive events with a set of problems.',
              'Join an active contest before it closes to participate.',
              'Solve as many problems as correctly and as quickly as possible to earn more points.',
              'Final standings are shown after the contest ends.',
            ],
          ),
          _GuideSection(
            emoji: '📖',
            color: const Color(0xFF9B6ED4),
            title: 'Blog',
            steps: const [
              'The Blog section contains articles, tips, and math guides written by the community.',
              'Read posts to deepen your understanding of topics you\'re working on.',
              'New posts are added regularly — check back often!',
            ],
          ),
          _GuideSection(
            emoji: '🤖',
            color: const Color(0xFF4A90D9),
            title: 'AI Tutor',
            steps: const [
              'Access the AI Tutor from the sidebar (tap the ☰ menu).',
              'Ask the AI any math question or request an explanation for a concept.',
              'You can also paste a problem you\'re stuck on and ask for hints or a walkthrough.',
              'The AI Tutor is available anytime — no waiting!',
            ],
          ),
          _GuideSection(
            emoji: '👥',
            color: const Color(0xFF3DAA6E),
            title: 'Friends',
            steps: const [
              'Find and follow other users from the Friends section in the sidebar.',
              'Search by username to find people you know.',
              'Visit a friend\'s profile to see their stats and progress.',
            ],
          ),
          _GuideSection(
            emoji: '👤',
            color: const Color(0xFFE89B2A),
            title: 'Your Profile',
            steps: const [
              'Tap your name at the top of the sidebar to open your profile.',
              'Your profile shows your rating, total submissions, accepted answers, and a breakdown by difficulty.',
              'Keep solving problems to increase your rating and climb the leaderboard!',
            ],
          ),

          const SizedBox(height: 8),

          // Tips card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kPrimary.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('💡', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TipRow(tip: 'Answers are case-insensitive — "Pi" and "pi" both work.'),
                _TipRow(tip: 'Use the Hint before giving up — it won\'t penalise your score.'),
                _TipRow(tip: 'Solve Easy problems first to build your rating quickly.'),
                _TipRow(tip: 'Check the leaderboard after each session to track your climb.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Guide section card ────────────────────────────────────────────────────────
class _GuideSection extends StatefulWidget {
  final String emoji;
  final Color color;
  final String title;
  final List<String> steps;

  const _GuideSection({
    required this.emoji,
    required this.color,
    required this.title,
    required this.steps,
  });

  @override
  State<_GuideSection> createState() => _GuideSectionState();
}

class _GuideSectionState extends State<_GuideSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header row
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _kTextDark,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: _kTextLight),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded steps
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: _kBorder),
                    const SizedBox(height: 12),
                    ...widget.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: TextStyle(
                                      color: widget.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _kTextMid,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tip row ───────────────────────────────────────────────────────────────────
class _TipRow extends StatelessWidget {
  final String tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: _kPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextMid,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}