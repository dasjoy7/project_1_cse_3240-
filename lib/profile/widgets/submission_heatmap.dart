import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_activity.dart';

class SubmissionHeatmap extends StatefulWidget {
  final List<DailyActivity> activities;

  const SubmissionHeatmap({super.key, required this.activities});

  @override
  State<SubmissionHeatmap> createState() => _SubmissionHeatmapState();
}

class _SubmissionHeatmapState extends State<SubmissionHeatmap> {
  // Default to current month and year
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Map<String, dynamic> getActivityData(DateTime date) {
    final activity = widget.activities.firstWhere(
      (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
      orElse: () => DailyActivity(date: date, count: 0),
    );

    Color color;
    if (activity.count == 0) color = Colors.grey.shade200;
    else if (activity.count == 1) color = Colors.green.shade200;
    else if (activity.count < 4) color = Colors.green.shade400;
    else color = Colors.green.shade700;

    return {'color': color, 'count': activity.count};
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = _getDaysInMonth(_selectedDate.year, _selectedDate.month);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Activity Map", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  // MONTH PICKER
                  _buildDropdown(
                    value: _selectedDate.month,
                    items: List.generate(12, (i) => i + 1),
                    labelBuilder: (val) => DateFormat('MMM').format(DateTime(2024, val)),
                    onChanged: (val) => setState(() => _selectedDate = DateTime(_selectedDate.year, val!)),
                  ),
                  const SizedBox(width: 10),
                  // YEAR PICKER (Last 5 years)
                  _buildDropdown(
                    value: _selectedDate.year,
                    items: List.generate(5, (i) => DateTime.now().year - i),
                    labelBuilder: (val) => val.toString(),
                    onChanged: (val) => setState(() => _selectedDate = DateTime(val!, _selectedDate.month)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(daysInMonth, (index) {
              final day = DateTime(_selectedDate.year, _selectedDate.month, index + 1);
              final data = getActivityData(day);
              
              return Tooltip(
                message: "${DateFormat('MMM dd, yyyy').format(day)}: ${data['count']} submissions",
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: data['color'],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text("${index + 1}", 
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold,
                        color: data['count'] > 0 ? Colors.white : Colors.grey.shade500)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDropdown({required int value, required List<int> items, required String Function(int) labelBuilder, required ValueChanged<int?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 16),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
        onChanged: onChanged,
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(labelBuilder(val)))).toList(),
      ),
    );
  }

  Widget _buildLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Less", style: TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(width: 4),
        _LegendSquare(color: Color(0xFFEEEEEE)),
        _LegendSquare(color: Color(0xFFA9DFBF)),
        _LegendSquare(color: Color(0xFF2ECC71)),
        _LegendSquare(color: Color(0xFF1D8348)),
        SizedBox(width: 4),
        Text("More", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _LegendSquare extends StatelessWidget {
  final Color color;
  const _LegendSquare({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 1),
    width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
  );
}