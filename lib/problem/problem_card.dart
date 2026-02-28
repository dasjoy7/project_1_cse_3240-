import 'package:flutter/material.dart';
import 'problem_model.dart';

// ── Theme constants (mirrors MainWrapper palette) ──────────────────────────
const _kPrimary    = Color(0xFF4A90D9);
const _kSurface    = Color(0xFFF7F9FC);
const _kCardWhite  = Color(0xFFFFFFFF);
const _kTextDark   = Color(0xFF1E2A3B);
const _kTextMid    = Color(0xFF5A6A7E);
const _kTextLight  = Color(0xFF8FA0B4);
const _kBorder     = Color(0xFFEAEFF6);
// ───────────────────────────────────────────────────────────────────────────

class ProblemCard extends StatelessWidget {
  final ProblemModel problem;
  final VoidCallback onTap;

  const ProblemCard({super.key, required this.problem, required this.onTap});

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':   return const Color(0xFF3DAA6E);   // soft green
      case 'medium': return const Color(0xFFE89B2A);   // warm amber
      case 'hard':   return const Color(0xFFE05555);   // soft red
      default:       return _kTextLight;
    }
  }

  IconData _difficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':   return Icons.signal_cellular_alt_1_bar_rounded;
      case 'medium': return Icons.signal_cellular_alt_2_bar_rounded;
      case 'hard':   return Icons.signal_cellular_alt_rounded;
      default:       return Icons.signal_cellular_alt_1_bar_rounded;
    }
  }

  Widget _solvedBadge() {
    if (problem.userSolvedCorrectly == null) return const SizedBox.shrink();
    if (problem.userSolvedCorrectly == true) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF3DAA6E).withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.check_rounded,
            color: Color(0xFF3DAA6E), size: 16),
      );
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE05555).withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.close_rounded,
          color: Color(0xFFE05555), size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(problem.difficulty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: _kPrimary.withOpacity(0.06),
          highlightColor: _kPrimary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        problem.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kTextDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _solvedBadge(),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags + submission count
                Row(
                  children: [
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: diffColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: diffColor.withOpacity(0.30), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_difficultyIcon(problem.difficulty),
                              color: diffColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            problem.difficulty,
                            style: TextStyle(
                              color: diffColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Sub-category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        problem.subCategory,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Submission count
                    Icon(Icons.people_outline_rounded,
                        size: 13, color: _kTextLight),
                    const SizedBox(width: 3),
                    Text(
                      '${problem.totalSubmission}',
                      style: const TextStyle(
                          fontSize: 12, color: _kTextLight),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: _kTextLight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}