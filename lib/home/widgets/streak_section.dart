import 'package:flutter/material.dart';
import '../home_models.dart';

class StreakSection extends StatefulWidget {
  final StreakInfo streak;
  const StreakSection({super.key, required this.streak});

  @override
  State<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends State<StreakSection> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  Set<String> get _activeSet => widget.streak.activeDays
      .map((d) => '${d.year}-${d.month}-${d.day}')
      .toSet();

  void _prevMonth() {
    setState(() {
      if (_selectedMonth == 1) { _selectedMonth = 12; _selectedYear--; }
      else { _selectedMonth--; }
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth == now.month) return;
    setState(() {
      if (_selectedMonth == 12) { _selectedMonth = 1; _selectedYear++; }
      else { _selectedMonth++; }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _selectedYear == now.year && _selectedMonth == now.month;
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    int activeDaysInMonth = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      if (_activeSet.contains('$_selectedYear-$_selectedMonth-$d')) activeDaysInMonth++;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Text('Daily Streak',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.streak.currentStreak}d streak',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left,
                    size: 18, color: Color(0xFF1E88E5)),
              ),
              GestureDetector(
                onTap: _showYearPicker,
                child: Row(
                  children: [
                    Text(
                      '${_months[_selectedMonth - 1]} $_selectedYear',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        size: 14, color: Color(0xFF1E88E5)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isCurrentMonth ? null : _nextMonth,
                child: Icon(Icons.chevron_right,
                    size: 18,
                    color: isCurrentMonth
                        ? Colors.grey.shade300
                        : const Color(0xFF1E88E5)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => SizedBox(
              width: 26,
              child: Text(d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600)),
            ))
                .toList(),
          ),

          const SizedBox(height: 4),

          // Calendar grid
          _buildCalendarGrid(startWeekday, daysInMonth, now),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          const SizedBox(height: 8),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('🔥', 'Current', '${widget.streak.currentStreak}'),
              _miniStat('⚡', 'Longest', '${widget.streak.longestStreak}'),
              _miniStat('📅', 'This Month', '$activeDaysInMonth'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int startWeekday, int daysInMonth, DateTime now) {
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final dayNumber = row * 7 + col - startWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 26, height: 26);
              }

              final key = '$_selectedYear-$_selectedMonth-$dayNumber';
              final isActive = _activeSet.contains(key);
              final isToday = now.year == _selectedYear &&
                  now.month == _selectedMonth &&
                  now.day == dayNumber;
              final isFuture = DateTime(_selectedYear, _selectedMonth, dayNumber)
                  .isAfter(now);

              return Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isFuture
                      ? const Color(0xFFF9F9F9)
                      : isActive
                      ? const Color(0xFF43A047)
                      : const Color(0xFFEEF0F5),
                  borderRadius: BorderRadius.circular(5),
                  border: isToday
                      ? Border.all(color: const Color(0xFFFF6B35), width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 9,
                    color: isFuture
                        ? Colors.grey.shade300
                        : isActive
                        ? Colors.white
                        : isToday
                        ? const Color(0xFFFF6B35)
                        : Colors.grey.shade500,
                    fontWeight: isActive || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  void _showYearPicker() {
    final now = DateTime.now();
    final years = List.generate(5, (i) => now.year - i);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Year',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              children: years.map((y) {
                final selected = y == _selectedYear;
                return GestureDetector(
                  onTap: () { setState(() => _selectedYear = y); Navigator.pop(context); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1E88E5) : const Color(0xFFEEF0F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$y',
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 3),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E))),
          ],
        ),
        Text(label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
      ],
    );
  }
}