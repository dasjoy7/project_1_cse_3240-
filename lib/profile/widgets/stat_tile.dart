import 'package:flutter/cupertino.dart';

class StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal:2,vertical:2),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),//4
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon,color:color,size:18),
          SizedBox(height:4),
          Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize:18,fontWeight: FontWeight.bold,color: color),
          ),
          Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize:12),
          ),
        ],
      ),
    );
  }
}