import 'package:flutter/material.dart';
import '../profile_daily_submission.dart';
import 'heatmap_utils.dart';

class SubmissionHeatmap extends StatelessWidget {
  final List<DailySubmission> data;

  const SubmissionHeatmap({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String,int>map={
      for(var d in data)
        "${d.date.year}-${d.date.month}-${d.date.day}":d.count
    };
    final today=DateTime.now();
    final days=List.generate(90,(i){
      final date=today.subtract(Duration(days:i));
      final key="${date.year}-${date.month}-${date.day}";
      return {
        'date':date,
        'count':map[key]??0,
      };
    }).reversed.toList();
    return Wrap(
      spacing:4,
      runSpacing:4,
      children: days.map((item) {
        final DateTime date=item['date'] as DateTime;
        final int count=item['count'] as int;
        final formattedDate =
            "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2, '0')}";


        return Tooltip(
          message:"$formattedDate\n$count submissions",
          waitDuration:Duration(milliseconds:200),
          child: Container(
            width:14,
            height:14,
            decoration: BoxDecoration(
              color: heatmapColor(count),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }).toList(),
    );
  }
}

