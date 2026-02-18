import 'package:flutter/material.dart';

Color heatmapColor(int count) {
  if (count==0) return Colors.grey.shade200;
  if (count<=1) return Colors.green.shade100;
  if (count<=3) return Colors.green.shade300;
  if (count<=6) return Colors.green.shade500;
  return Colors.green.shade700;
}