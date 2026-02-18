import 'package:flutter/material.dart';
import 'package:project_1_cse_3240/problems/theme/app_colors.dart';

class DifficultyChip extends StatelessWidget {
  final String level;DifficultyChip({super.key,required this.level});
  @override
  Widget build(BuildContext context) {
    Color bg; Color text;
    switch(level)
    {
      case 'Easy':
        bg = easyColor;
        text = easyText;
        break;
      case 'Medium':
        bg = mediumColor;
        text = mediumText;
        break;
      default:
        bg = hardColor;
        text = hardText;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal:10,vertical: 4),
      decoration: BoxDecoration(
        color:bg,
        borderRadius: BorderRadius.circular(12),),
      child: Text(level,
        style: TextStyle(color: text,fontWeight: FontWeight.bold),
      ),
    );
  }
}