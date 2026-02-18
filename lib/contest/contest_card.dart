import 'package:flutter/material.dart';
import 'dart:async';

class ContestCard extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final String category;
  final String duration;
  final bool isRunning;
  final bool isCompleted;
  final VoidCallback? onAnalysisTap;

  const ContestCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.category,
    required this.duration,
    required this.isRunning,
    required this.isCompleted,
    this.onAnalysisTap,
  }) : super(key: key);

  @override
  _ContestCardState createState() => _ContestCardState();
}

class _ContestCardState extends State<ContestCard> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (!widget.isCompleted) {
      _calculateRemainingTime();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _calculateRemainingTime();
        });
      });
    }
  }

  void _calculateRemainingTime() {
    try {
      final contestDateTime = DateTime.parse('${widget.date} ${widget.time}');
      final now = DateTime.now();

      if (now.isBefore(contestDateTime)) {
        _remainingTime = contestDateTime.difference(now);
      } else {
        _remainingTime = Duration.zero;
      }
    } catch (e) {
      _remainingTime = Duration.zero;
    }
  }

  @override
  void dispose() {
    if (!widget.isCompleted) {
      _timer.cancel();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? Colors.grey.shade300
                        : widget.isRunning
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isCompleted
                          ? Colors.grey.shade500
                          : widget.isRunning
                          ? Colors.green
                          : Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    widget.isCompleted
                        ? 'Completed'
                        : widget.isRunning
                        ? 'Live'
                        : 'Upcoming',
                    style: TextStyle(
                      color: widget.isCompleted
                          ? Colors.grey.shade700
                          : widget.isRunning
                          ? Colors.green.shade800
                          : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Contest Info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.date,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.time,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category and Duration
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.category,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.duration,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),

            // Countdown Timer (only for non-completed contests)
            if (!widget.isCompleted && !widget.isRunning) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_bottom,
                        size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Starts in: ${_formatDuration(_remainingTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // View Analysis Button (only for completed contests)
            if (widget.isCompleted && widget.onAnalysisTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onAnalysisTap,
                  icon: const Icon(Icons.analytics),
                  label: const Text('View Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}