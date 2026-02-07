import 'package:flutter/material.dart';

class ContestCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final String category;
  final String duration;
  final bool isRunning;  // Field to check if the contest is running
  final bool isCompleted;  // Field to check if the contest is completed

  const ContestCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.category,
    required this.duration,
    required this.isRunning,  // Add this to receive the running status
    required this.isCompleted,  // Add this to receive the completed status
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),

              // Description/SubTitle
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),

              // Date and Time
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Category
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(
                  category,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),

              // Duration
              Text(
                'Duration: $duration',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              // Show Running status if the contest is running
              if (isRunning && !isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text(
                      'Running',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green, // Green for running
                  ),
                ),
              
              // Show Completed status if the contest is completed
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text(
                      'Completed',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red, // Red for completed
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
